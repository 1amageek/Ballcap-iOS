//
//  StorageBatch.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/11.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseStorage

public enum StorageBatchError: Error {
    case invalidData(File)
    case timeout

    public var description: String {
        switch self {
        case .invalidData(let file): return "[Ballcap: StorageBatch] Invalid file. \(file)"
        case .timeout: return "[Ballcap: StorageBatch] StorageBatch updload has timed out."
        }
    }
}

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
    public func save(_ file: File) -> Self {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        self._storage.append((.save, file))
        return self
    }

    @discardableResult
    public func save(_ files: [File]) -> Self {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        files.forEach({ self._storage.append((.save, $0)) })
        return self
    }

    @discardableResult
    public func delete(_ file: File) -> Self {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        self._storage.append((.delete, file))
        return self
    }

    @discardableResult
    public func delete(_ files: [File]) -> Self {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        files.forEach({ self._storage.append((.delete, $0)) })
        return self
    }

    @discardableResult
    public func commit(_ completion: ((Error?) -> Void)? = nil) -> [File] {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        if self._storage.isEmpty {
            completion?(nil)
            return []
        }
        var commitingFiles: [File] = []
        for (_, stock) in self._storage.enumerated() {
            commitingFiles.append(stock.file)
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
                    completion?(StorageBatchError.timeout)
                }
            }
        }
        return commitingFiles
    }
}
