//
//  Object.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol Modelable: Equatable & Referencable {
    init()
}

public extension Modelable {
    
    static var modelVersion: String {
        return "1"
    }

    static var modelName: String {
        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
    }

    static var path: String {
        return "version/\(self.modelVersion)/\(self.modelName)"
    }

    static var collectionReference: CollectionReference {
        return Firestore.firestore().collection(self.path)
    }
}

public enum DocumentError: Error {
    case snapshotNotExists
    case invalidReference
    case invalidData
    case timeout

    public var description: String {
        switch self {
        case .snapshotNotExists: return "DocumentSnapshot is not exists."
        case .invalidReference: return "The value you are trying to reference is invalid."
        case .invalidData: return "Invalid data."
        case .timeout: return "DataSource fetch timed out."
        }
    }
}

open class Object: Documentable {

    public enum CachePolicy {
        case `default`          // cache then network
        case cacheOnly
        case networkOnly
    }

    public static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.id == rhs.id
    }

    public internal(set) var documentReference: DocumentReference!

    public internal(set) var snapshot: DocumentSnapshot?

    public internal(set) var createdAt: Timestamp = Timestamp(date: Date())

    public internal(set) var updatedAt: Timestamp = Timestamp(date: Date())

    public required init(_ documentReference: DocumentReference) {
        self.documentReference = documentReference
    }
//
//    public required convenience init(id: String, collectionReference: CollectionReference? = nil) {
//        if let collectionReference: CollectionReference = collectionReference {
//            self.init(documentReference: collectionReference.document(id))
//        } else {
//            self.init(documentReference: Object.collectionReference.document(id))
//            self.documentReference = type(of: self).collectionReference.document(id)
//        }
//    }
}

public extension DataRepresentable where Self: Object {

    static var query: DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference)
    }

    // MARK: -

    static func `where`(_ field: String, isEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.whereField(field, isEqualTo: isEqualTo), reference: self.collectionReference)
    }

    static func `where`(_ field: String, isLessThan: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.whereField(field, isLessThan: isLessThan), reference: self.collectionReference)
    }

    static func `where`(_ field: String, isLessThanOrEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.whereField(field, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: self.collectionReference)
    }

    static func `where`(_ field: String, isGreaterThan: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.whereField(field, isGreaterThan: isGreaterThan), reference: self.collectionReference)
    }

    static func `where`(_ field: String, isGreaterThanOrEqualTo: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.whereField(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: self.collectionReference)
    }

    static func `where`(_ field: String, arrayContains: Any) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.whereField(field, arrayContains: arrayContains), reference: self.collectionReference)
    }

    static func order(by: String) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.order(by: by), reference: self.collectionReference)
    }

    static func order(by: String, descending: Bool) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.order(by: by, descending: descending), reference: self.collectionReference)
    }

    // MARK: -

    static func limit(to: Int) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.limit(to: to), reference: self.collectionReference)
    }

    static func start(at: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.start(at: at), reference: self.collectionReference)
    }

    static func start(after: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.start(after: after), reference: self.collectionReference)
    }

    static func start(atDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.start(atDocument: atDocument), reference: self.collectionReference)
    }

    static func start(afterDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.start(afterDocument: afterDocument), reference: self.collectionReference)
    }

    static func end(at: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.end(at: at), reference: self.collectionReference)
    }

    static func end(atDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.end(atDocument: atDocument), reference: self.collectionReference)
    }

    static func end(before: [Any]) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.end(before: before), reference: self.collectionReference)
    }

    static func end(beforeDocument: DocumentSnapshot) -> DataSource<Self>.Query {
        return DataSource.Query(self.collectionReference.end(beforeDocument: beforeDocument), reference: self.collectionReference)
    }
}
