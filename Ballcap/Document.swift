//
//  Document.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol Modelable: Equatable {
    init()
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

public class Document: Documentable {

    public enum CachePolicy {
        case `default`          // cache then network
        case cacheOnly
        case networkOnly
    }

    public static func == (lhs: Document, rhs: Document) -> Bool {
        return lhs.id == rhs.id
    }

    public private(set) var documentReference: DocumentReference!

    public internal(set) var snapshot: DocumentSnapshot?

    public internal(set) var createdAt: Timestamp = Timestamp(date: Date())

    public internal(set) var updatedAt: Timestamp = Timestamp(date: Date())

    public required init(documentReference: DocumentReference) {
        self.documentReference = documentReference
    }
}

//public class Document<Model: Codable & Modelable>: Documentable {
//
//    public static func == (lhs: Document<Model>, rhs: Document<Model>) -> Bool {
//        return lhs.id == rhs.id && lhs.data == rhs.data
//    }
//
//    public typealias Model = Model
//
//    public enum CachePolicy {
//        case `default`          // cache then network
//        case cacheOnly
//        case networkOnly
//    }
//
//    public var isIncludedInTimestamp: Bool {
//        return Model.isIncludedInTimestamp
//    }
//
//    public var id: String {
//        return self.documentReference.documentID
//    }
//
//    public var path: String {
//        return self.documentReference.path
//    }
//
//    public private(set) var snapshot: DocumentSnapshot?
//
//    public private(set) var documentReference: DocumentReference!
//
//    public var storageReference: StorageReference {
//        return Storage.storage().reference().child(self.path)
//    }
//
//    public var data: Model?
//
//    public var cache: Model? {
//        return Store.shared.get(modelType: Model.self, reference: self.documentReference)
//    }
//
//    public private(set) var createdAt: Timestamp = Timestamp(date: Date())
//
//    public private(set) var updatedAt: Timestamp = Timestamp(date: Date())
//
//    public init() {
//        self.data = Model()
//        self.documentReference = Model.collectionReference.document()
//    }
//
//    public convenience init(collectionReference: CollectionReference) {
//        self.init()
//        self.documentReference = collectionReference.document()
//    }
//
//    public convenience init(id: String, collectionReference: CollectionReference? = nil) {
//        self.init()
//        self.documentReference = collectionReference?.document(id) ?? Model.collectionReference.document(id)
//    }
//
//    public convenience init(id: String, from data: Model, collectionReference: CollectionReference? = nil) {
//        self.init()
//        self.documentReference = collectionReference?.document(id) ?? Model.collectionReference.document(id)
//    }
//
//    public required convenience init?(id: String, from data: [String: Any], collectionReference: CollectionReference? = nil) {
//        self.init()
//        do {
//            self.data = try Firestore.Decoder().decode(Model.self, from: data)
//            self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
//            self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
//        } catch (let error) {
//            print(error)
//            return nil
//        }
//        self.documentReference = collectionReference?.document(id) ?? Model.collectionReference.document(id)
//    }
//
//    public convenience init?(snapshot: DocumentSnapshot) {
//        self.init()
//        guard let data: [String: Any] = snapshot.data() else {
//            self.snapshot = snapshot
//            self.documentReference = snapshot.reference
//            return
//        }
//        do {
//            self.data = try Firestore.Decoder().decode(Model.self, from: data)
//            self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
//            self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
//        } catch (let error) {
//            print(error)
//            return nil
//        }
//        self.snapshot = snapshot
//        self.documentReference = snapshot.reference
//    }
//
//    public subscript<T: Any>(keyPath: WritableKeyPath<Model, T>) -> T? {
//        get {
//            return self.data?[keyPath: keyPath]
//        }
//        set {
//            self.data?[keyPath: keyPath] = newValue!
//        }
//    }
//
//    public func collection<SubCollectionModel: Modelable & Codable>(key: String) -> DataSource<SubCollectionModel>.Query {
//        let collectionReference: CollectionReference = self.documentReference.collection(key)
//        return DataSource.Query(collectionReference)
//    }
//
//    public func collection<SubCollectionModel: Modelable & Codable>(key: String, type: SubCollectionModel.Type) -> DataSource<SubCollectionModel>.Query {
//        let collectionReference: CollectionReference = self.documentReference.collection(key)
//        return DataSource.Query(collectionReference)
//    }
//}
//
// MARK: -

//public extension Document where Self: DataRepresentable {
//
//    func save(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
//        let batch: Batch = Batch()
//        batch.save(document: self)
//        batch.commit(completion)
//    }
//
//    func update(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
//        let batch: Batch = Batch()
//        batch.update(document: self)
//        batch.commit(completion)
//    }
//
//    func delete(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
//        let batch: Batch = Batch()
//        batch.delete(document: self)
//        batch.commit(completion)
//    }
//}

//// MARK: -
//
//public extension Document {
//
//    class func get(documentReference: DocumentReference, cachePolicy: CachePolicy = .default, completion: @escaping ((Document?, Error?) -> Void)) {
//        switch cachePolicy {
//        case .default:
//            if let document: Document = self.get(documentReference: documentReference) {
//                completion(document, nil)
//            }
//            documentReference.getDocument { (snapshot, error) in
//                if let error = error {
//                    completion(nil, error)
//                    return
//                }
//                guard let snapshot = snapshot, snapshot.exists else {
//                    completion(nil, DocumentError.invalidData)
//                    return
//                }
//                guard let document: Document = Document(snapshot: snapshot) else {
//                    completion(nil, DocumentError.invalidData)
//                    return
//                }
//                completion(document, nil)
//            }
//        case .cacheOnly:
//            if let document: Document = self.get(documentReference: documentReference) {
//                completion(document, nil)
//            }
//            documentReference.getDocument(source: FirestoreSource.cache) { (snapshot, error) in
//                if let error = error {
//                    completion(nil, error)
//                    return
//                }
//                guard let snapshot = snapshot, snapshot.exists else {
//                    completion(nil, DocumentError.invalidData)
//                    return
//                }
//                guard let document: Document = Document(snapshot: snapshot) else {
//                    completion(nil, DocumentError.invalidData)
//                    return
//                }
//                completion(document, nil)
//            }
//        case .networkOnly:
//            documentReference.getDocument(source: FirestoreSource.server) { (snapshot, error) in
//                if let error = error {
//                    completion(nil, error)
//                    return
//                }
//                guard let snapshot = snapshot, snapshot.exists else {
//                    completion(nil, DocumentError.invalidData)
//                    return
//                }
//                guard let document: Document = Document(snapshot: snapshot) else {
//                    completion(nil, DocumentError.invalidData)
//                    return
//                }
//                completion(document, nil)
//            }
//        }
//    }
//
//    class func get(id: String, cachePolicy: CachePolicy = .default, completion: @escaping ((Document?, Error?) -> Void)) {
//        let documentReference: DocumentReference = Document.init(id: id).documentReference
//        self.get(documentReference: documentReference, cachePolicy: cachePolicy, completion: completion)
//    }
//
//    class func get(documentReference: DocumentReference) -> Document? {
//        return Store.shared.get(documentType: self, reference: documentReference)
//    }
//
//    class func listen(id: String, includeMetadataChanges: Bool = true, completion: @escaping ((Document?, Error?) -> Void)) -> Disposer {
//        let listenr: ListenerRegistration = Model.collectionReference.document(id).addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//            guard let document: Document = Document(snapshot: snapshot!) else {
//                completion(nil, DocumentError.invalidData)
//                return
//            }
//            completion(document, nil)
//        }
//        return Disposer(.value(listenr))
//    }
//}
//
//public extension Document where Model.CollectionPaths: RawRepresentable, Model.CollectionPaths.RawValue == String {
//
//    func collection<SubCollectionModel: Modelable & Codable>(path: Model.CollectionPaths, type: SubCollectionModel.Type) -> DataSource<SubCollectionModel>.Query {
//        let collectionReference: CollectionReference = self.documentReference.collection(path.rawValue)
//        return DataSource.Query(collectionReference)
//    }
//
//    func collection<SubCollectionModel: Modelable & Codable>(path: Model.CollectionPaths) -> DataSource<SubCollectionModel>.Query {
//        let collectionReference: CollectionReference = self.documentReference.collection(path.rawValue)
//        return DataSource.Query(collectionReference)
//    }
//}
//
public extension DataRepresentable where Self: Document {

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
