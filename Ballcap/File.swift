
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
    case invalidData(File)
    case timeout

    public var description: String {
        switch self {
        case .invalidData(let file): return "[Ballcap: File] Invalid data.\(file)"
        case .timeout: return "[Ballcap: File] File updload has timed out."
        }
    }
}

public final class File: Hashable {
    
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

        public var rawValue: String {
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

        public var fileExtension: String {
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

    public var path: String

    /// ConentType
    public var mimeType: MIMEType = .octetStream(nil)

    /// Save data
    public var data: Data?

    /// File download URL
    public var url: URL?

    private var originalURL: URL?

    /// File name
    public var name: String {
        get {
            return self.storageReference.name
        }
        set {
            if let parent = self.storageReference.parent() {
                self.storageReference = parent.child(newValue)
            } else {
                self.storageReference = Storage.storage().reference(withPath: newValue)
            }
        }
    }

    /// File metadata
    public private(set) var metadata: StorageMetadata?

    /// File uploaded
    public var isUploaded: Bool {
        return self.metadata?.updated != nil || self.url != nil
    }

    /// Additinal Data
    public var additionalData: [String: String] = [:]

    /// Firebase uploading task
    private(set) weak var uploadTask: StorageUploadTask?

    /// Firebase downloading task
    private(set) weak var downloadTask: StorageDownloadTask?

    // MARK: - Initialize

    public init(_ storageReference: StorageReference, data: Data? = nil, mimeType: MIMEType? = nil) {
        let (name, mimeType) = File.generateFileName(storageReference.name, mimeType: mimeType)
        if let parent = storageReference.parent() {
            self.storageReference = parent.child(name)
        } else {
            self.storageReference = Storage.storage().reference(withPath: name)
        }
        self.path = self.storageReference.fullPath
        self.mimeType = mimeType
        self.data = data
        self.uploadTask = StorageTaskStore.shared.get(upload: storageReference.fullPath)
        self.downloadTask = StorageTaskStore.shared.get(download: storageReference.fullPath)
    }

    public convenience init<T: Documentable>(_ object: T,
                                             name: String? = nil,
                                             data: Data? = nil,
                                             mimeType: MIMEType? = nil) {
        let (fileName, mimeType) = File.generateFileName(name ?? "\(Int(Date().timeIntervalSince1970 * 1000))", mimeType: mimeType)
        let reference: StorageReference = object.storageReference.child(fileName)
        self.init(reference, data: data, mimeType: mimeType)
    }

    internal convenience init(path: String, url: URL?, mimeType: File.MIMEType, additionalData: [String: String]) {
        let storageReference: StorageReference = Storage.storage().reference().child(path)
        self.init(storageReference)
        self.url = url
        self.mimeType = mimeType
        self.additionalData = additionalData
    }

    class func generateFileName(_ name: String, mimeType: MIMEType?) -> (String, MIMEType) {
        var fileName: String = name
        let nameURL: URL = URL(string: name)!
        if let mimeType: MIMEType = mimeType {
            fileName = nameURL.pathExtension.isEmpty ? nameURL.appendingPathExtension(mimeType.fileExtension).absoluteString : name
            return (fileName, mimeType)
        }
        guard !nameURL.pathExtension.isEmpty else {
            return (fileName, .octetStream(nil))
        }
        guard let mimeType: MIMEType = MIMEType(ext: nameURL.pathExtension) else {
            fatalError("This file has invalid extension.")
        }
        return (fileName, mimeType)
    }

    class func mimeType(for ext: String) -> MIMEType? {
        return MIMEType(ext: ext)
    }

    // MARK: - SAVE

    @discardableResult
    public func save(_ completion: ((StorageMetadata?, Error?) -> Void)?) -> StorageUploadTask? {

        let reference: StorageReference = self.storageReference
        let metadata: StorageMetadata = StorageMetadata()
        metadata.contentType = mimeType.rawValue

        if let data: Data = self.data {
            let task: StorageUploadTask = reference.putData(data, metadata: metadata) { (metadata, error) in
                self.metadata = metadata
                if let error = error {
                    completion?(metadata, error)
                    return
                }
                StorageCache.shared.set(data, reference: reference)
                reference.downloadURL(completion: { (url, error) in
                    if let error = error {
                        completion?(metadata, error)
                        return
                    }
                    self.url = url
                    completion?(metadata, error)
                })
            }
            StorageTaskStore.shared.set(upload: self.path, task: task)
            self.uploadTask = task
            return self.uploadTask
        } else if let url: URL = self.originalURL {
            let task: StorageUploadTask = reference.putFile(from: url, metadata: metadata) { (metadata, error) in
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
            StorageTaskStore.shared.set(upload: self.path, task: task)
            self.uploadTask = task
            return self.uploadTask
        } else {
            let error: FileError = .invalidData(self)
            completion?(nil, error)
            return nil
        }
    }

    // MARK: - DELETE

    public func delete(_ completion: ((Error?) -> Void)?) {
        self.storageReference.delete { (error) in
            self.metadata = nil
            self.url = nil
            self.data = nil
            StorageCache.shared.delete(reference: self.storageReference)
            completion?(error)
        }
    }

    // MARK: - RETRIEVE

    /// Default 100MB
    @discardableResult
    public func getData(_ size: Int64 = Int64(10e8), completion: @escaping (Data?, Error?) -> Void) -> StorageDownloadTask? {
        self.downloadTask?.cancel()
        if let data: Data = self.data {
            completion(data, nil)
            return nil
        }
        guard let data: Data = StorageCache.shared.get(self.storageReference) else {
            let task: StorageDownloadTask = self.storageReference.getData(maxSize: size, completion: { (data, error) in
                self.data = data
                self.downloadTask = nil
                if let data = data {
                    StorageCache.shared.set(data, reference: self.storageReference)
                }
                completion(data, error as Error?)
            })
            return task
        }
        completion(data, nil)
        let task: StorageDownloadTask = self.storageReference.getData(maxSize: size, completion: { (networkData, error) in
            self.downloadTask = nil
            if let networkData = networkData, data != networkData {
                self.data = networkData
                StorageCache.shared.set(networkData, reference: self.storageReference)
                completion(data, error as Error?)
            }
        })
        StorageTaskStore.shared.set(download: self.path, task: task)
        self.downloadTask = task
        return task
    }

    // MARK: -

    public var description: String {
        let base: String =
            "      path: \(self.path)\n" +
            "      name: \(self.name)\n" +
            "      url: \(self.url?.absoluteString ?? "")\n" +
            "      mimeType: \(self.mimeType.rawValue)\n" +
            "      additionalData: \(self.additionalData)\n" +
        "    "
        return "\n    File {\n\(base)}"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.path)
    }

    public static func == (lhs: File, rhs: File) -> Bool {
        return lhs.name == rhs.name && lhs.url == rhs.url && lhs.mimeType == rhs.mimeType
    }
}
