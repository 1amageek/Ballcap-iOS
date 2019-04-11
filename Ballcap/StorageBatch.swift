//
//  StorageBatch.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/11.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

public final class StorageBatch {

    enum BatchType {
        case save
        case delete
    }

    private let _queue: DispatchQueue = DispatchQueue(label: "StorageManager.queue")

    private let _group: DispatchGroup = DispatchGroup()

    private var _isCommitted: Bool = false

    private var _storage: [(type: BatchType, file: File)] = []

    var timeout: Int = 10 // Default 10s

    public init() { }

    @discardableResult
    public func save(file: File) -> Self {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        self._storage.append((.save, file))
        return self
    }

    @discardableResult
    public func delete(file: File) -> Self {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        self._storage.append((.delete, file))
        return self
    }

    public func commit(_ completion: ((Error?) -> Void)? = nil) {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        if self._storage.isEmpty {
            completion?(nil)
            return
        }
        for (_, stock) in self._storage.enumerated() {
            switch stock.type {
            case .save:
                self._group.enter()
                stock.file.save { [weak self] (metadata, error) in
                    self?._group.leave()
                }
            case .delete:
                self._group.enter()
                stock.file.delete { [weak self] (error) in
                    self?._group.leave()
                }
            }
        }
        self._queue.async {
            switch self._group.wait(timeout: .now() + .seconds(self.timeout)) {
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
    }
}
