//
//  FileManager.swift
//  Ballcap
//
//  Created by 1amageek on 2019/10/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

public final class FileManager {

    public static let shared: FileManager = FileManager()

    public func get(storageReference: StorageReference) -> Data? {
        return FileCache.shared.get(storageReference)
    }

    public func get(key: String) -> Data? {
        return FileCache.shared.get(key)
    }

    public func set(storageReference: StorageReference, data: Data) {
        FileCache.shared.set(data, reference: storageReference)
    }

    public func set(key: String, data: Data) {
        FileCache.shared.set(key: key, data: data)
    }

    public func delete(reference: StorageReference) {
        FileCache.shared.delete(reference: reference)
    }

    public func delete(key: String) {
        FileCache.shared.delete(key: key)
    }
}
