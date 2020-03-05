//
//  File+Codable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/30.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage


private protocol CodableFile: Codable {
    var url: URL? { get }
    var path: String { get }
    var mimeType: File.MIMEType { get }
    var metadata: [String: String] { get }
    init(path: String, url: URL?, mimeType: File.MIMEType, metadata: [String: String])
}

private enum FileKeys: String, CodingKey {
    case path
    case url
    case mimeType
    case metadata
}

extension CodableFile {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FileKeys.self)
        let path = try container.decode(String.self, forKey: .path)
        let url = try container.decode(URL?.self, forKey: .url)
        let mimeType = try container.decode(File.MIMEType.self, forKey: .mimeType)
        let metadata = try container.decode([String: String].self, forKey: .metadata)
        self.init(path: path, url: url, mimeType: mimeType, metadata: metadata)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FileKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(url, forKey: .url)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(metadata, forKey: .metadata)
    }
}

/** Extends File to conform to Codable. */
extension File: CodableFile { }

