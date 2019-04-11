//
//  StorageManager.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/09.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

internal final class StorageManager {

    let queue: DispatchQueue = DispatchQueue(label: "StorageManager.queue")

    let group: DispatchGroup = DispatchGroup()

    let files: [File]

    var timeout: Int = 10 // Default 10s

    init(files: [File]) {
        self.files = files
    }

    @discardableResult
    func upload(completion: ((Error?) -> Void)?) -> [File] {
        var uploadingFiles: [File] = []
        for (_, file) in files.enumerated() {
            if !file.isUploaded {
                uploadingFiles.append(file)
                group.enter()
                file.save { [weak self] (metadata, error) in
                    self?.group.leave()
                }
            }
        }
        self.queue.async {
            switch self.group.wait(timeout: .now() + .seconds(self.timeout)) {
            case .success:
                DispatchQueue.main.async {
                    completion?(nil)
                }
            case .timedOut:
                DispatchQueue.main.async {
                    completion?(DocumentError.timeout)
                }
            }
        }
        return uploadingFiles
    }

    func delete(completion: ((Error?) -> Void)?) -> [File] {
        var deletingFiles: [File] = []
        for (_, file) in files.enumerated() {
            if file.isUploaded {
                deletingFiles.append(file)
                group.enter()
                file.delete { [weak self]  (error) in
                    self?.group.leave()
                }
            }
        }
        self.queue.async {
            switch self.group.wait(timeout: .now() + .seconds(self.timeout)) {
            case .success:
                DispatchQueue.main.async {
                    completion?(nil)
                }
            case .timedOut:
                DispatchQueue.main.async {
                    completion?(DocumentError.timeout)
                }
            }
        }
        return deletingFiles
    }
}
