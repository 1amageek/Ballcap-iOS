
//  File.swift
//  Pring
//
//  Created by 1amageek on 2017/10/05.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public enum FileError: Error {
    case invalidData
    case timeout

    public var description: String {
        switch self {
        case .invalidData: return "Invalid data."
        case .timeout: return "File updload timed out."
        }
    }
}

public final class File: Equatable {
    
    public enum MIMEType: Codable, Equatable {
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let mimeType: String = try container.decode(String.self)
            self = MIMEType(rawValue: mimeType) ?? MIMEType.custom("", "")
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        }

        case plain
        case csv
        case html
        case css
        case javascript
        case octetStream(String?)
        case pdf
        case zip
        case tar
        case lzh
        case jpeg
        case pjpeg
        case png
        case gif
        case mp4
        case custom(String, String)

        var rawValue: String {
            switch self {
            case .plain:                 return "text/plain"
            case .csv:                   return "text/csv"
            case .html:                  return "text/html"
            case .css:                   return "text/css"
            case .javascript:            return "text/javascript"
            case .octetStream:           return "application/octet-stream"
            case .pdf:                   return "application/pdf"
            case .zip:                   return "application/zip"
            case .tar:                   return "application/x-tar"
            case .lzh:                   return "application/x-lzh"
            case .jpeg:                  return "image/jpeg"
            case .pjpeg:                 return "image/pjpeg"
            case .png:                   return "image/png"
            case .gif:                   return "image/gif"
            case .mp4:                   return "video/mp4"
            case .custom(let type, _):   return type
            }
        }

        var fileExtension: String {
            switch self {
            case .plain:                 return "txt"
            case .csv:                   return "csv"
            case .html:                  return "html"
            case .css:                   return "css"
            case .javascript:            return "js"
            case .octetStream(let ext):  return ext ?? ""
            case .pdf:                   return "pdf"
            case .zip:                   return "zip"
            case .tar:                   return "tar"
            case .lzh:                   return "lzh"
            case .jpeg:                  return "jpg"
            case .pjpeg:                 return "jpg"
            case .png:                   return "png"
            case .gif:                   return "gif"
            case .mp4:                   return "mp4"
            case .custom(_, let ext):    return ext
            }
        }

        init?(rawValue: String, ext: String? = nil) {
            switch rawValue {
            case "text/plain":                  self = .plain
            case "text/csv":                    self = .csv
            case "text/html":                   self = .html
            case "text/css":                    self = .css
            case "text/javascript":             self = .javascript
            case "application/octet-stream":    self = .octetStream(ext ?? "")
            case "application/pdf":             self = .pdf
            case "application/zip":             self = .zip
            case "application/x-tar":           self = .tar
            case "application/x-lzh":           self = .lzh
            case "image/jpeg":                  self = .jpeg
            case "image/pjpeg":                 self = .pjpeg
            case "image/png":                   self = .png
            case "image/gif":                   self = .gif
            case "video/mp4":                   self = .mp4
            default:                            self = .custom(rawValue, ext ?? "")
            }
        }

        init?(ext: String) {
            switch ext {
            case "txt":         self = .plain
            case "csv":         self = .csv
            case "html":        self = .html
            case "css":         self = .css
            case "js":          self = .javascript
            case "pdf":         self = .pdf
            case "zip":         self = .zip
            case "tar":         self = .tar
            case "lzh":         self = .lzh
            case "jpeg", "jpg": self = .jpeg
            case "png":         self = .png
            case "gif":         self = .gif
            case "mp4":         self = .mp4
            default:            self = .custom("", ext)
            }
        }

    }

    private(set) var storageReference: StorageReference

    /// Path to Storage
    var path: String

    /// ConentType
    var mimeType: MIMEType

    /// Save data
    var data: Data?

    /// File download URL
    var url: URL?

    private var originalURL: URL?

    /// File name
    var name: String

    /// File metadata
    var metadata: StorageMetadata?

    ///
    var additionalData: [String: String]?

    /// Firebase uploading task
    private(set) weak var uploadTask: StorageUploadTask?

    /// Firebase downloading task
    private(set) weak var downloadTask: StorageDownloadTask?

    // MARK: - Initialize

    init(_ storageReference: StorageReference, name: String? = nil, mimeType: MIMEType? = nil) {
        self.storageReference = storageReference
        self.path = storageReference.fullPath
        let (fileName, mimeType) = File.generateFileName(name ?? "\(Int(Date().timeIntervalSince1970 * 1000))", mimeType: mimeType)
        self.name = fileName
        self.mimeType = mimeType
    }

    convenience init(_ storageReference: StorageReference,
                     data: Data,
                     name: String? = nil,
                     mimeType: MIMEType? = nil) {
        self.init(storageReference, name: name, mimeType: mimeType)
        self.data = data
    }

    convenience init(_ storageReference: StorageReference,
                     url: URL,
                     name: String? = nil,
                     mimeType: MIMEType? = nil) {
        self.init(storageReference, name: name, mimeType: mimeType)
        self.originalURL = url
    }

    internal convenience init(path: String, name: String, url: URL?, mimeType: File.MIMEType, additionalData: [String: String]?) {
        let storageReference: StorageReference = Storage.storage().reference().child(path)
        self.init(storageReference, name: name)
        self.url = url
        self.mimeType = mimeType
        self.additionalData = additionalData
    }

    class func generateFileName(_ name: String, mimeType: MIMEType?) -> (String, MIMEType) {
        var fileName: String = name
        let url: URL = URL(string: name)!
        if let mimeType: MIMEType = mimeType {
            fileName = url.pathExtension.isEmpty ? url.appendingPathExtension(mimeType.fileExtension).absoluteString : name
            return (fileName, mimeType)
        }
        guard !url.pathExtension.isEmpty else {
            fatalError("This file has invalid extension.")
        }
        guard let mimeType: MIMEType = MIMEType(ext: url.pathExtension) else {
            fatalError("This file has invalid extension.")
        }
        return (fileName, mimeType)
    }

    class func mimeType(for ext: String) -> MIMEType? {
        return MIMEType(ext: ext)
    }

    // MARK: - SAVE

    func save(_ completion: ((StorageMetadata?, Error?) -> Void)?) -> StorageUploadTask? {

        let reference: StorageReference = self.storageReference
        let metadata: StorageMetadata = StorageMetadata()
        metadata.contentType = mimeType.rawValue

        if let data: Data = self.data {
            self.uploadTask = reference.putData(data, metadata: metadata) { (metadata, error) in
                self.metadata = metadata
                if let error = error {
                    completion?(metadata, error)
                    return
                }
                reference.downloadURL(completion: { (url, error) in
                    if let error = error {
                        completion?(metadata, error)
                        return
                    }
                    self.url = url
                    completion?(metadata, error)
                })
            }
            return self.uploadTask
        } else if let url: URL = self.originalURL {
            self.uploadTask = reference.putFile(from: url, metadata: metadata) { (metadata, error) in
                self.metadata = metadata
                if let error = error {
                    completion?(metadata, error)
                    return
                }
                reference.downloadURL(completion: { (url, error) in
                    if let error = error {
                        completion?(metadata, error)
                        return
                    }
                    self.url = url
                    completion?(metadata, error)
                })
            }
            return self.uploadTask
        } else {
            let error: FileError = .invalidData
            completion?(nil, error)
            return nil
        }
    }

    // MARK: - DELETE

    func delete(_ completion: ((Error?) -> Void)?) {
        self.storageReference.delete { (error) in
            completion?(error)
        }
    }

    // MARK: - RETRIEVE

    /// Default 100MB
    func getData(_ size: Int64 = Int64(10e8), completion: @escaping (Data?, Error?) -> Void) -> StorageDownloadTask? {
        self.downloadTask?.cancel()
        let task: StorageDownloadTask? = self.storageReference.getData(maxSize: size, completion: { (data, error) in
            self.downloadTask = nil
            completion(data, error as Error?)
        })
        self.downloadTask = task
        return task
    }

    // MARK: -

    var description: String {
        let base: String =
            "      name: \(self.name)\n" +
            "      url: \(self.url?.absoluteString ?? "")\n" +
            "      path: \(self.path)\n" +
            "      mimeType: \(self.mimeType.rawValue)\n" +
            "      additionalData: \(self.additionalData ?? [:])\n" +
            "    "
        return "\n    File {\n\(base)}"
    }
}

public func == (lhs: File, rhs: File) -> Bool {
    return
        lhs.path == rhs.path &&
        lhs.name == rhs.name &&
        lhs.url == rhs.url &&
        lhs.mimeType == rhs.mimeType
}

//extension Array where Element: File {
//
//    internal func _dispose(_ block: @escaping ([Error]) -> Void) {
//        let queue: DispatchQueue = DispatchQueue(label: "Pring.File.disposal.queue")
//        let group: DispatchGroup = DispatchGroup()
//        queue.async {
//            var errors: [Error] = []
//            self.forEach { (file) in
//                group.enter()
//                file.ref?.delete(completion: { (error) in
//                    defer {
//                        group.leave()
//                    }
//                    if let error = error {
//                        errors.append(error)
//                    }
//                })
//            }
//            group.notify(queue: DispatchQueue.main, execute: {
//                block(errors)
//            })
//            switch group.wait(timeout: .now() + .seconds(30)) {
//            case .success: break
//            case .timedOut:
//                let error: DocumentError = DocumentError(kind: .timeout, description: "File deletion processing timed out.")
//                errors.append(error)
//                DispatchQueue.main.async {
//                    block(errors)
//                }
//            }
//        }
//    }
//}
