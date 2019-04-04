//
//  Query.swift
//  Pring
//
//  Created by 1amageek on 2017/11/08.
//  Copyright © 2017年 Stamp Inc. All rights reserved.
//
//  Contact us https://twitter.com/1amageek

import FirebaseFirestore
import FirebaseStorage

public extension DataSource {

    class Query {

        public private(set) var reference: CollectionReference

        public private(set) var query: FirebaseFirestore.Query

        public init(_ reference: CollectionReference) {
            self.reference = reference
            self.query = reference
        }

        public init(_ query: FirebaseFirestore.Query, reference: CollectionReference) {
            self.reference = reference
            self.query = query
        }

        public func dataSource(option: DataSourceOption = DataSourceOption()) -> DataSource<Model> {
            return DataSource(reference: self, option: option)
        }

        // MARK: -

        public func `where`(_ keyPath: String, isEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath, isEqualTo: isEqualTo), reference: self.reference)
        }

        public func `where`(_ keyPath: String, isLessThan: Any) -> Query {
            return Query(query.whereField(keyPath, isLessThan: isLessThan), reference: self.reference)
        }

        public func `where`(_ keyPath: String, isLessThanOrEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.reference)
        }

        public func `where`(_ keyPath: String, isGreaterThan: Any) -> Query {
            return Query(query.whereField(keyPath, isGreaterThan: isGreaterThan), reference: self.reference)
        }

        public func `where`(_ keyPath: String, isGreaterThanOrEqualTo: Any) -> Query {
            return Query(query.whereField(keyPath, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.reference)
        }

        public func `where`(_ keyPath: String, arrayContains: Any) -> Query {
            return Query(query.whereField(keyPath, arrayContains: arrayContains), reference: self.reference)
        }

        public func order(by: String) -> Query {
            return Query(query.order(by: by), reference: self.reference)
        }

        public func order(by: String, descending: Bool) -> Query {
            return Query(query.order(by: by, descending: descending), reference: self.reference)
        }

        public func filter(using: NSPredicate) -> Query {
            return Query(query.filter(using: using), reference: self.reference)
        }

        // MARK: -

        public func limit(to: Int) -> Query {
            return Query(query.limit(to: to), reference: self.reference)
        }

        public func start(at: [Any]) -> Query {
            return Query(query.start(at: at), reference: self.reference)
        }

        public func start(after: [Any]) -> Query {
            return Query(query.start(after: after), reference: self.reference)
        }

        public func start(atDocument: DocumentSnapshot) -> Query {
            return Query(query.start(atDocument: atDocument), reference: self.reference)
        }

        public func start(afterDocument: DocumentSnapshot) -> Query {
            return Query(query.start(afterDocument: afterDocument), reference: self.reference)
        }

        public func end(at: [Any]) -> Query {
            return Query(query.end(at: at), reference: self.reference)
        }

        public func end(atDocument: DocumentSnapshot) -> Query {
            return Query(query.end(atDocument: atDocument), reference: self.reference)
        }

        public func end(before: [Any]) -> Query {
            return Query(query.end(before: before), reference: self.reference)
        }

        public func end(beforeDocument: DocumentSnapshot) -> Query {
            return Query(query.end(beforeDocument: beforeDocument), reference: self.reference)
        }

        public func listen(includeMetadataChanges: Bool = true, listener: @escaping FIRQuerySnapshotBlock) -> ListenerRegistration {
            return query.addSnapshotListener(includeMetadataChanges: includeMetadataChanges, listener: listener)
        }

        public func get(completion: @escaping FIRQuerySnapshotBlock) {
            query.getDocuments(completion: completion)
        }
    }
}
