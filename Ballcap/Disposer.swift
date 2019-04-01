//
//  Disposer.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

/// A protocol for disposer
public protocol ReferenceObservationDisposable {
    /// Execute T.removeObserver()
    func dispose()
}

/// Disposer
/// Handle removing observer using handle_id (and child_id) on `deinit` automatically.
public final class Disposer: ReferenceObservationDisposable {
    public enum ObserveType {
        case none
        case array(ListenerRegistration)
        case value(ListenerRegistration)

        public var listener: ListenerRegistration? {
            switch self {
            case .array(let listener):
                return listener
            case .value(let listener):
                return listener
            default:
                return nil
            }
        }
    }

    private let type: ObserveType

    private var isDisposed = false

    private let lock = NSLock()

    public init(_ type: ObserveType = .none) {
        self.type = type
        if case .none = type {
            isDisposed = true
        }
    }

    public func dispose() {
        lock.lock(); defer { lock.unlock() }
        if isDisposed { return }
        switch type {
        case .array(let listener): listener.remove()
        case .value(let listener): listener.remove()
        default:
            break
        }
        isDisposed = true
    }

    public func toAny() -> AnyDisposer {
        return .init(self)
    }

    deinit {
        dispose()
    }
}

///  A type-erased `Disposer`.
public final class AnyDisposer: ReferenceObservationDisposable {

    public let base: ReferenceObservationDisposable

    public init(_ base: ReferenceObservationDisposable = NoDisposer()) {
        self.base = base
    }

    public func dispose() {
        base.dispose()
    }

    deinit {
        dispose()
    }
}

/// A disposer that do nothing.
public final class NoDisposer: ReferenceObservationDisposable {
    public init() { }
    public func dispose() { }
}
