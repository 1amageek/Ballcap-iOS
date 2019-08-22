//
//  DataSource.swift
//  Ballcap
//
//  Created by 1amageek on 2017/10/06.
//  Copyright © 2019年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public enum DataSourceError: Error {
    case timeout

    var description: String {
        switch self {
        case .timeout: return "DataSource fetch timed out."
        }
    }
}

/// DataSource class.
/// Observe at a Firebase DataSource location.
public final class DataSource<T: Object & DataRepresentable>: ExpressibleByArrayLiteral {

    public typealias ArrayLiteralElement = T

    public typealias Element = ArrayLiteralElement

    public typealias RetrieveBlock = (QuerySnapshot?, QueryDocumentSnapshot, @escaping ((Element) -> Void)) -> Void

    public typealias ChangedBlock = (QuerySnapshot?, Snapshot) -> Void

    public typealias ErrorBlock = (QuerySnapshot?, DataSourceError) -> Void

    public typealias Changes = (deletions: [Element], insertions: [Element], modifications: [Element])

    public struct Snapshot {

        public let before: [Element]

        public let after: [Element]

        public let changes: Changes

        init(before: [Element], after: [Element], changes: Changes) {
            self.before = before
            self.after = after
            self.changes = changes
        }
    }

    /// Objects held in the client
    public var documents: [Element] = []

    /// Count
    public var count: Int { return documents.count }

    /// True if we have the last Document of the data source
    public private(set) var isLast: Bool = false

    /// Reference of element
    public private(set) var query: Query

    /// DataSource Option
    public private(set) var option: Option

    private let fetchQueue: DispatchQueue = DispatchQueue(label: "ballcap.datasource.fetch.queue")

    private var listenr: ListenerRegistration?

    /// Holds the Key previously sent to Firebase.
    private var previousLastKey: String?


    private var _changedBlock: ChangedBlock?

    private var _retrieveBlock: RetrieveBlock?

    private var _sortedBlock: (T, T) throws -> Bool = { $0.updatedAt > $1.updatedAt }

    private var errorBlock: ErrorBlock?

    /**
     DataSource retrieves data from the referenced data. Change the acquisition of data by setting Options.
     If there is a change in the value, it will receive and notify you of the change.

     Handler blocks are called on the same thread that they were added on, and may only be added on threads which are
     currently within a run loop. Unless you are specifically creating and running a run loop on a background thread,
     this will normally only be the main thread.

     - parameter reference: Set DatabaseDeference
     - parameter option: DataSource Option
     */
    public init(reference: Query, option: Option = Option()) {
        self.query = reference
        self.option = option
    }

    /// Initializing the DataSource
    public required convenience init(arrayLiteral documents: Element...) {
        self.init(documents)
    }

    /// Initializing the DataSource
    public init(_ documents: [Element]) {
        self.query = Element.query
        self.option = Option()
        self.documents = documents
    }

    @discardableResult
    public func retrieve(from block: RetrieveBlock?) -> Self {
        self._retrieveBlock = block
        return self
    }

    @discardableResult
    public func onChanged(_ block: ChangedBlock?) -> Self {
        self._changedBlock = block
        return self
    }

    @discardableResult
    public func sorted(by areInIncreasingOrder: @escaping (T, T) throws -> Bool) rethrows -> Self {
        self._sortedBlock = areInIncreasingOrder
        self.documents = try self.documents.sorted(by: areInIncreasingOrder)
        return self
    }

    @discardableResult
    public func onError(_ block: ErrorBlock?) -> Self {
        self.errorBlock = block
        return self
    }

    /// Start monitoring data source.
    @discardableResult
    public func listen() -> Self {
        self.listenr = self.query.listen(includeMetadataChanges: true, listener: { [weak self] (snapshot, error) in
            guard let `self` = self else { return }
            guard let snapshot: QuerySnapshot = snapshot else {
                return
            }
            guard let lastSnapshot = snapshot.documents.last else {
                return
            }
            if !snapshot.metadata.hasPendingWrites {
                self.query = self.query.start(afterDocument: lastSnapshot)
            }
            self._execute(snapshot: snapshot)
        })
        return self
    }

    /// Stop monitoring the data source.
    public func stop() {
        self.listenr?.remove()
    }

    private func _execute(snapshot: QuerySnapshot) {
        let errorBlock: ErrorBlock? = self.errorBlock
        let retrieveBlock: RetrieveBlock? = self._retrieveBlock
        let changedBlock: ChangedBlock? = self._changedBlock

        self.fetchQueue.async {
            var documents: [Element] = self.documents
            let group: DispatchGroup = DispatchGroup()
            var insertions: [Element] = []
            var modifications: [Element] = []
            var deletions: [Element] = []
            snapshot.documentChanges(includeMetadataChanges: true).forEach { change in
                let id: String = change.document.documentID
                switch change.type {
                case .added:
                    if !documents.keys.contains(id) {
                        if let retrieveBlock = retrieveBlock {
                            group.enter()
                            retrieveBlock(snapshot, change.document, { element in
                                if !documents.keys.contains(id) {
                                    insertions.append(element)
                                    documents.append(element)
                                }
                                group.leave()
                            })
                        }
                    }
                case .modified:
                    if documents.keys.contains(id) {
                        if let retrieveBlock = retrieveBlock {
                            group.enter()
                            retrieveBlock(snapshot, change.document, { element in
                                if let index: Int = documents.keys.firstIndex(of: id) {
                                    modifications.append(element)
                                    documents[index] = element
                                }
                                group.leave()
                            })
                        }
                    }
                case .removed:
                    if documents.keys.contains(id) {
                        if let retrieveBlock = retrieveBlock {
                            group.enter()
                            retrieveBlock(snapshot, change.document, { element in
                                if let index: Int = documents.keys.firstIndex(of: id) {
                                    deletions.append(element)
                                    documents.remove(at: index)
                                }
                                group.leave()
                            })
                        }
                    }
                @unknown default:
                    fatalError()
                }
            }
            switch group.wait(timeout: .now() + .seconds(self.option.timeout)) {
            case .success:
                let before: [Element] = self.documents
                self.documents = try! documents.sorted(by: self._sortedBlock)
                let after = self.documents
                let dataSourceSnapshot: Snapshot = Snapshot(before: before, after: after, changes: (deletions: deletions, insertions: insertions, modifications: modifications))
                DispatchQueue.main.async {
                    changedBlock?(snapshot, dataSourceSnapshot)
                }
            case .timedOut:
                let error: DataSourceError = DataSourceError.timeout
                errorBlock?(snapshot, error)
            }
        }
    }

    @discardableResult
    public func get() -> Self {
        self.next()
        return self
    }

    /// Load the next data from the data source.
    /// - Parameters:
    ///     - block: It returns `isLast` as an argument.
    @discardableResult
    public func next(_ block: ((Bool) -> Void)? = nil) -> Self {
        self.query.get { (snapshot, error) in
            guard let lastSnapshot = snapshot?.documents.last else {
                // The collection is empty.
                self.isLast = true
                block?(true)
                return
            }
            self.query = self.query.start(afterDocument: lastSnapshot)
            block?(false)
            self._execute(snapshot: snapshot!)
        }
        return self
    }

    // MARK: - deinit

    deinit {
        self.listenr?.remove()
    }
}

public extension DataSource {

    func add(document: Element) {
        let changedBlock: ChangedBlock? = self._changedBlock
        let before: [Element] = self.documents
        var documents: [Element] = self.documents
        let id: String = document.id
        if !documents.keys.contains(id) {
            documents.append(document)
            self.documents = try! documents.sorted(by: self._sortedBlock)
            let dataSourceSnapshot: Snapshot = Snapshot(before: before, after: self.documents, changes: (deletions: [], insertions: [document], modifications: []))
            changedBlock?(nil, dataSourceSnapshot)
        }
    }

    func remove(document: Element) {
        let changedBlock: ChangedBlock? = self._changedBlock
        let before: [Element] = self.documents
        var documents: [Element] = self.documents
        if let index: Int = self.documents.firstIndex(of: document.id) {
            documents.remove(at: index)
            let dataSourceSnapshot: Snapshot = Snapshot(before: before, after: self.documents, changes: (deletions: [document], insertions: [], modifications: []))
            changedBlock?(nil, dataSourceSnapshot)
        }
    }
}

public extension DataSource {
    /**
     Options class
     */
    struct Option {

        /// Fetch timeout
        public var timeout: Int = 10    // Default Timeout 10s

        public init() { }
    }
}

public extension Array where Element: Documentable {

    var keys: [String] {
        return self.compactMap { return $0.id }
    }

    func firstIndex(of key: String) -> Int? {
        return self.keys.firstIndex(of: key)
    }

    func firstIndex(of document: Element) -> Int? {
        return self.keys.firstIndex(of: document.id)
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

    public func firstIndex(of element: Element) -> Int? {
        if self.documents.isEmpty { return nil }
        return self.documents.firstIndex(of: element.id)
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
        if let index: Int = self.documents.firstIndex(of: member) {
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
