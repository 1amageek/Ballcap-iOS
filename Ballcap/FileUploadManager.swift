//
//  FileUploadManager.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/09.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

internal final class FileUploadManager {

    let queue: DispatchQueue = DispatchQueue(label: "file.upload.queue")

    let group: DispatchGroup = DispatchGroup()

    var files: [File] = []

    var timeout: Int = 10 // Default 10s

    func upload(completion: ((Error?) -> Void)?) -> [File] {
        var uploadingFiles: [File] = []
        var metadataes: [StorageMetadata] = []
        var errors: [Error] = []
        for (_, file) in files.enumerated() {
            if !file.isUploaded {
                uploadingFiles.append(file)
                group.enter()
                file.save { [weak self] (metadata, error) in
                    if let error = error {
                        errors.append(error)
                        return
                    }
                    metadataes.append(metadata!)
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
}
