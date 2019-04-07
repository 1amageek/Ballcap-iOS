//
//  StorageCache.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

internal final class StorageCache {

    static let shared: StorageCache = StorageCache()

    lazy var cache: NSCache<NSString, NSData> = {
        let cache: NSCache<NSString, NSData> = NSCache()
        return cache
    }()

    func get(_ reference: StorageReference) -> Data? {
        return self.cache.object(forKey: reference.fullPath as NSString) as Data?
    }

    func get(_ path: String) -> Data? {
        return self.cache.object(forKey: path as NSString) as Data?
    }

    func set(_ data: Data, reference: StorageReference) {
        self.set(key: reference.fullPath, data: data)
    }

    func set(key: String, data: Data) {
        self.cache.setObject(data as NSData, forKey: key as NSString)
    }

    func delete(reference: StorageReference) {
        self.delete(key: reference.fullPath)
    }

    func delete(key: String) {
        self.cache.removeObject(forKey: key as NSString)
    }
}

