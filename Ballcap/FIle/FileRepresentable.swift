//
//  FileRepresentable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/10/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

public protocol FileRepresentable {

    var file: File { get }

}

public extension FileRepresentable {

    /// Firebase uploading task
    internal(set) var uploadTask: StorageUploadTask? {
        get {
            StorageTaskStore.shared.get(upload: file.path)
        }
        set {
            StorageTaskStore.shared.set(upload: file.path, task: newValue)
        }
    }

    /// Firebase downloading task
    internal(set) weak var downloadTask: StorageDownloadTask? {
        get {
            StorageTaskStore.shared.get(download: file.path)
        }
        set {
            StorageTaskStore.shared.set(download: file.path, task: newValue)
        }
    }

    /// Default 100MB
    @discardableResult
    func load(_ size: Int64 = Int64(10e8), completion: ((File?, Error?) -> Void)? = nil) -> StorageDownloadTask? {
        self.downloadTask?.cancel()
        guard let _ = file.data else {
            let storageReference: StorageReference = file.storageReference
            let task: StorageDownloadTask = storageReference.getData(maxSize: size, completion: { (data, error) in
                if let data = data {
                    self.file.data = data
                }
                completion?(self.file, error as Error?)
            })
            StorageTaskStore.shared.set(download: file.path, task: task)
            return task
        }
        completion?(file, nil)
        return nil
    }

    func cancel() {
        self.downloadTask?.cancel()
    }
}
