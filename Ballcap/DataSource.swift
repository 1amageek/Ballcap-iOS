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

    public typealias ChangedBlock = (QuerySnapshot?, Change) -> Void

    public typealias ErrorBlock = (QuerySnapshot?, DataSourceError) -> Void

    public typealias Change = (deletions: [Element], insertions: [Element], modifications: [Element])


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
     - parameter options: DataSource Options
     - parameter block: A block which is called to process Firebase change evnet.
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

        var documents: [Element] = self.documents

        self.fetchQueue.async {
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
                                insertions.append(element)
                                documents.append(element)
                                group.leave()
                            })
                        }
                    }
                case .modified:
                    if let index: Int = documents.keys.firstIndex(of: id) {
                        if let retrieveBlock = retrieveBlock {
                            group.enter()
                            retrieveBlock(snapshot, change.document, { element in
                                modifications.append(element)
                                documents[index] = element
                                group.leave()
                            })
                        }
                    }
                case .removed:
                    if let index: Int = documents.keys.firstIndex(of: id) {
                        if let retrieveBlock = retrieveBlock {
                            group.enter()
                            retrieveBlock(snapshot, change.document, { element in
                                deletions.append(element)
                                documents.remove(at: index)
                                group.leave()
                            })
                        }
                    }
                @unknown default:
                    fatalError()
                }
            }
            group.notify(queue: DispatchQueue.main, execute: {
                self.documents = try! documents.sorted(by: self._sortedBlock)
                changedBlock?(snapshot, (deletions: deletions, insertions: insertions, modifications: modifications))
            })
            switch group.wait(timeout: .now() + .seconds(self.option.timeout)) {
            case .success: break
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
        var documents: [Element] = self.documents
        let id: String = document.id
        if !documents.keys.contains(id) {
            documents.append(document)
            self.documents = try! documents.sorted(by: self._sortedBlock)
            changedBlock?(nil, (deletions: [], insertions: [document], modifications: []))
        }
    }

    func remove(document: Element) {
        let changedBlock: ChangedBlock? = self._changedBlock
        var documents: [Element] = self.documents
        if let index: Int = self.documents.index(of: document.id) {
            documents.remove(at: index)
            changedBlock?(nil, (deletions: [document], insertions: [], modifications: []))
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

    func index(of key: String) -> Int? {
        return self.keys.firstIndex(of: key)
    }

    func index(of document: Element) -> Int? {
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
