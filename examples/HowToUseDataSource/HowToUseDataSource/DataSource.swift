//
//  DataSource.swift
//  HowToUseDataSource
//
//  Created by 1amageek on 2019/08/19.
//  Copyright © 2019 Stamp. All rights reserved.
//

import FirebaseFirestore
import Ballcap

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public protocol Handler {

    func handle()
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct EmptyHandler {

    @inlinable public init() {

    }

    public func handle() {

    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Added {

    @inlinable public init() {

    }

    public func handle() {

    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct Modified {

    @inlinable public init() {

    }

    public func handle() {

    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
@_functionBuilder public struct HandleBuilder {


    public static func buildBlock() -> EmptyHandler { EmptyHandler() }

    public static func buildBlock<Content>(_ content: Content) where Content : Handler {
        content.handle()
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension HandleBuilder {
    public static func buildBlock<C0, C1>(_ c0: C0, _ c1: C1) where C0 : Handler, C1 : Handler {
        c0.handle()
        c1.handle()
    }

    public static func buildBlock<C0, C1, C2>(_ c0: C0, _ c1: C1, _ c2: C2) where C0 : Handler, C1 : Handler, C2 : Handler {
        c0.handle()
        c1.handle()
        c2.handle()
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
extension HandleBuilder {

}


final public class DataSource<T: Object & DataRepresentable> {

    public typealias ArrayLiteralElement = T

    public typealias Element = ArrayLiteralElement

    public var includeMetadataChanges: Bool = true

    private var _sortedBlock: (T, T) throws -> Bool = { $0.updatedAt > $1.updatedAt }

    private var _executeBlock: ((_ snapshot: QuerySnapshot) -> Void)?

    /// Objects held in the client
    fileprivate var documents: [Element] = []

    /// Reference of element
    public private(set) var query: Ballcap.DataSource<Element>.Query

    public init(reference: Ballcap.DataSource<Element>.Query) {
        self.query = reference
    }

    public func sorted(by areInIncreasingOrder: @escaping (T, T) throws -> Bool) rethrows -> Self {
        self._sortedBlock = areInIncreasingOrder
        return self
    }

    public func excute(_ block: @escaping (_ snapshot: QuerySnapshot) -> Void) -> Self {
        self._executeBlock = block
        return self
    }

    private func _execute(snapshot: QuerySnapshot) {

    }

    private var listenr: ListenerRegistration?

    public func listen() -> Self {
        self.listenr = self.query.listen(includeMetadataChanges: self.includeMetadataChanges, listener: { [weak self] (snapshot, error) in
            guard let `self` = self else { return }
            guard let snapshot: QuerySnapshot = snapshot else {
//                changeBlock?(nil, CollectionChange(change: nil, error: error))
                return
            }
            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.

                return
            }
            if !snapshot.metadata.hasPendingWrites {
                self.query = self.query.start(afterDocument: lastSnapshot)
            }
            self._execute(snapshot: snapshot)
        })
        return self
    }
}

/**
 DataSource conforms to Collection
 */
extension DataSource: Collection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return self.documents.count
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public func index(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        if self.documents.isEmpty { return nil }
        return try self.documents.firstIndex(where: predicate)
    }

    public func index(of element: Element) -> Int? {
        if self.documents.isEmpty { return nil }
        return self.documents.index(of: element.id)
    }

    public var first: Element? {
        if self.documents.isEmpty { return nil }
        return self.documents[startIndex]
    }

    public var last: Element? {
        if self.documents.isEmpty { return nil }
        return self.documents[endIndex - 1]
    }

    public func insert(_ newMember: Element) {
        if !self.documents.contains(newMember) {
            self.documents.append(newMember)
        }
    }

    public func remove(_ member: Element) {
        if let index: Int = self.documents.index(of: member) {
            self.documents.remove(at: index)
        }
    }

    public subscript(index: Int) -> Element {
        return self.documents[index]
    }

    public func forEach(_ body: (Element) throws -> Void) rethrows {
        return try self.documents.forEach(body)
    }
}
