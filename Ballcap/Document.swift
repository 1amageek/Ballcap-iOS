//
//  Document.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol Modelable: Referencable {
    init()
    static var isIncludedInTimestamp: Bool { get }

    associatedtype CollectionPaths = Void
}

public extension Modelable {

    static var isIncludedInTimestamp: Bool {
        return true
    }

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

public protocol Documentable {
    associatedtype Model

    var id: String { get }

    var path: String { get }
}

public enum DocumentError: Error {
    case invalidReference
    case invalidData
    case timeout

    public var description: String {
        switch self {
        case .invalidReference: return "The value you are trying to reference is invalid."
        case .invalidData: return "Invalid data."
        case .timeout: return "DataSource fetch timed out."
        }
    }
}

public class Document<Model: Codable & Modelable>: NSObject, Documentable {

    public typealias Model = Model

    public enum CachePolicy {
        case `default`          // cache then network
        case cacheOnly
        case networkOnly
    }

    public var isIncludedInTimestamp: Bool {
        return Model.isIncludedInTimestamp
    }

    public var id: String {
        return self.documentReference.documentID
    }

    public var path: String {
        return self.documentReference.path
    }

    public private(set) var snapshot: DocumentSnapshot?

    public private(set) var documentReference: DocumentReference!

    public var storageReference: StorageReference {
        return Storage.storage().reference().child(self.path)
    }

    public var data: Model?

    public private(set) var createdAt: Timestamp = Timestamp(date: Date())

    public private(set) var updatedAt: Timestamp = Timestamp(date: Date())

    public override init() {
        self.data = Model()
        super.init()
        self.documentReference = Model.collectionReference.document()
    }

    public init(collectionReference: CollectionReference) {
        self.data = Model()
        super.init()
        self.documentReference = collectionReference.document()
    }

    public init(id: String, collectionReference: CollectionReference? = nil) {
        self.data = Model()
        super.init()
        self.documentReference = collectionReference?.document(id) ?? Model.collectionReference.document(id)
    }

    public init(id: String, from data: Model, collectionReference: CollectionReference? = nil) {
        self.data = data
        super.init()
        self.documentReference = collectionReference?.document(id) ?? Model.collectionReference.document(id)
    }

    public required init?(id: String, from data: [String: Any], collectionReference: CollectionReference? = nil) {
        do {
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
            self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
            self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
        } catch (let error) {
            print(error)
            return nil
        }
        super.init()
        self.documentReference = collectionReference?.document(id) ?? Model.collectionReference.document(id)
    }

    public init?(snapshot: DocumentSnapshot) {
        guard let data: [String: Any] = snapshot.data() else {
            super.init()
            self.snapshot = snapshot
            self.documentReference = snapshot.reference
            return
        }
        do {
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
            self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
            self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
        } catch (let error) {
            print(error)
            return nil
        }
        super.init()
        self.snapshot = snapshot
        self.documentReference = Model.collectionReference.document(id)
    }

    public subscript<T: Any>(keyPath: WritableKeyPath<Model, T>) -> T? {
        get {
            return self.data?[keyPath: keyPath]
        }
        set {
            self.data?[keyPath: keyPath] = newValue!
        }
    }

    public func collection<SubCollectionModel: Modelable & Codable>(key: String) -> DataSource<SubCollectionModel>.Query {
        let collectionReference: CollectionReference = self.documentReference.collection(key)
        return DataSource.Query(collectionReference)
    }

    public func collection<SubCollectionModel: Modelable & Codable>(key: String, type: SubCollectionModel.Type) -> DataSource<SubCollectionModel>.Query {
        let collectionReference: CollectionReference = self.documentReference.collection(key)
        return DataSource.Query(collectionReference)
    }
}

// MARK: -

public extension Document {

    func save(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.save(document: self)
        batch.commit(completion)
    }

    func update(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.update(document: self)
        batch.commit(completion)
    }

    func delete(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.delete(document: self)
        batch.commit(completion)
    }
}

// MARK: -

public extension Document {

    class func get(id: String, cachePolicy: CachePolicy = .default, completion: @escaping ((Document?, Error?) -> Void)) {

        switch cachePolicy {
        case .default:
            if let document: Document = self.get(id: id) {
                completion(document, nil)
            }
            Model.collectionReference.document(id).getDocument { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot!) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        case .cacheOnly:
            if let document: Document = self.get(id: id) {
                completion(document, nil)
            }
            Model.collectionReference.document(id).getDocument(source: FirestoreSource.cache) { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot!) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        case .networkOnly:
            Model.collectionReference.document(id).getDocument(source: FirestoreSource.server) { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot!) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        }
    }

    class func get(id: String) -> Document? {
        return Store.shared.get(documentType: self, id: id)
    }

    class func listen(id: String, includeMetadataChanges: Bool = true, completion: @escaping ((Document?, Error?) -> Void)) -> Disposer {
        let listenr: ListenerRegistration = Model.collectionReference.document(id).addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let document: Document = Document(snapshot: snapshot!) else {
                completion(nil, DocumentError.invalidData)
                return
            }
            completion(document, nil)
        }
        return Disposer(.value(listenr))
    }
}

public extension Document where Model.CollectionPaths: RawRepresentable, Model.CollectionPaths.RawValue == String {

    func collection<SubCollectionModel: Modelable & Codable>(path: Model.CollectionPaths, type: SubCollectionModel.Type) -> DataSource<SubCollectionModel>.Query {
        let collectionReference: CollectionReference = self.documentReference.collection(path.rawValue)
        return DataSource.Query(collectionReference)
    }

    func collection<SubCollectionModel: Modelable & Codable>(path: Model.CollectionPaths) -> DataSource<SubCollectionModel>.Query {
        let collectionReference: CollectionReference = self.documentReference.collection(path.rawValue)
        return DataSource.Query(collectionReference)
    }
}

public extension Document {

    static var query: DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference)
    }

    // MARK:

    static func `where`(_ field: String, isEqualTo: Any) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.whereField(field, isEqualTo: isEqualTo), reference: Model.collectionReference)
    }

    static func `where`(_ field: String, isLessThan: Any) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.whereField(field, isLessThan: isLessThan), reference: Model.collectionReference)
    }

    static func `where`(_ field: String, isLessThanOrEqualTo: Any) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.whereField(field, isLessThanOrEqualTo: isLessThanOrEqualTo), reference: Model.collectionReference)
    }

    static func `where`(_ field: String, isGreaterThan: Any) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.whereField(field, isGreaterThan: isGreaterThan), reference: Model.collectionReference)
    }

    static func `where`(_ field: String, isGreaterThanOrEqualTo: Any) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.whereField(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo), reference: Model.collectionReference)
    }

    static func `where`(_ field: String, arrayContains: Any) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.whereField(field, arrayContains: arrayContains), reference: Model.collectionReference)
    }

    static func order(by: String) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.order(by: by), reference: Model.collectionReference)
    }

    static func order(by: String, descending: Bool) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.order(by: by, descending: descending), reference: Model.collectionReference)
    }

    // MARK: -

    static func limit(to: Int) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.limit(to: to), reference: Model.collectionReference)
    }

    static func start(at: [Any]) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.start(at: at), reference: Model.collectionReference)
    }

    static func start(after: [Any]) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.start(after: after), reference: Model.collectionReference)
    }

    static func start(atDocument: DocumentSnapshot) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.start(atDocument: atDocument), reference: Model.collectionReference)
    }

    static func start(afterDocument: DocumentSnapshot) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.start(afterDocument: afterDocument), reference: Model.collectionReference)
    }

    static func end(at: [Any]) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.end(at: at), reference: Model.collectionReference)
    }

    static func end(atDocument: DocumentSnapshot) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.end(atDocument: atDocument), reference: Model.collectionReference)
    }

    static func end(before: [Any]) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.end(before: before), reference: Model.collectionReference)
    }

    static func end(beforeDocument: DocumentSnapshot) -> DataSource<Model>.Query {
        return DataSource.Query(Model.collectionReference.end(beforeDocument: beforeDocument), reference: Model.collectionReference)
    }
}
