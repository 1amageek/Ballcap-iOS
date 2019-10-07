//
//  StorageTaskStore.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/02.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

internal final class StorageTaskStore {

    static let shared: StorageTaskStore = StorageTaskStore()

    private var uploadTaskStorage: [String: StorageUploadTask] = [:]

    private var downloadTaskStorage: [String: StorageDownloadTask] = [:]

    // MARK: UPLOAD

    func set(upload path: String, task: StorageUploadTask?) {
        self.uploadTaskStorage[path] = task
        let deleteTask: (StorageTaskSnapshot) -> Void = { [weak self] (snapshot) in
            self?.uploadTaskStorage.removeValue(forKey: path)
        }
        task?.observe(.success, handler: deleteTask)
        task?.observe(.failure, handler: deleteTask)
    }

    func get(upload path: String) -> StorageUploadTask? {
        return self.uploadTaskStorage.keys.contains(path) ? self.uploadTaskStorage[path] : nil
    }

    // MARK: DOWNLOAD

    func set(download path: String, task: StorageDownloadTask?) {
        self.downloadTaskStorage[path] = task
        let deleteTask: (StorageTaskSnapshot) -> Void = { [weak self] (snapshot) in
            self?.downloadTaskStorage.removeValue(forKey: path)
        }
        task?.observe(.success, handler: deleteTask)
        task?.observe(.failure, handler: deleteTask)
    }

    func get(download path: String) -> StorageDownloadTask? {
        return self.downloadTaskStorage[path]
    }
}
