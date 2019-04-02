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
    var path: String { get }
    var url: URL? { get }
    var name: String { get }
    var mimeType: File.MIMEType { get }
    var additionalData: [String: String]? { get }
    init(path: String, name: String, url: URL?, mimeType: File.MIMEType, additionalData: [String: String]?)
}

private enum FileKeys: String, CodingKey {
    case path
    case url
    case name
    case mimeType
    case additionalData
}

extension CodableFile {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FileKeys.self)
        let path = try container.decode(String.self, forKey: .path)
        let url = try container.decode(URL?.self, forKey: .url)
        let name = try container.decode(String.self, forKey: .name)
        let mimeType = try container.decode(File.MIMEType.self, forKey: .mimeType)
        let additionalData = try container.decode([String: String]?.self, forKey: .additionalData)
        self.init(path: path, name: name, url: url, mimeType: mimeType, additionalData: additionalData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: FileKeys.self)
        try container.encode(path, forKey: .path)
        try container.encode(url, forKey: .url)
        try container.encode(name, forKey: .name)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(additionalData, forKey: .additionalData)
    }
}

/** Extends File to conform to Codable. */
extension File: CodableFile { }

