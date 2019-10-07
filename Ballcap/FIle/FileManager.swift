//
//  FileManager.swift
//  Ballcap
//
//  Created by 1amageek on 2019/10/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

internal final class FileManager {

    static let shared: FileManager = FileManager()

    func get(storageReference: StorageReference) -> Data? {
        return FileCache.shared.get(storageReference)
    }

    func set(_ data: Data?, storageReference: StorageReference) {
        if let data: Data = data {
            FileCache.shared.set(data, reference: storageReference)
        } else {
            FileCache.shared.delete(reference: storageReference)
        }
    }
}
