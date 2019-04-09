//
//  DataRepresentable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public protocol DataRepresentable: class {

    associatedtype Model: Modelable & Codable

    var data: Model? { get set }
}

public extension DataRepresentable where Self: Object {

    init() {
        self.init(Self.collectionReference.document())
        self.data = Model()
    }

    init(collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document())
        self.data = Model()
    }

    init(id: String, collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document(id))
        self.data = Model()
    }

    init?(id: String, from data: [String: Any], collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document(id))
        do {
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
            if data.keys.contains("createdAt") {
                self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
            }
            if data.keys.contains("updatedAt") {
                self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
            }
        } catch (let error) {
            print(error)
            return nil
        }
    }

    init?(snapshot: DocumentSnapshot) {
        self.init(snapshot.reference)
        self.snapshot = snapshot
        guard let data: [String: Any] = snapshot.data(with: .estimate) else {
            self.snapshot = snapshot
            return
        }
        do {
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
            if data.keys.contains("createdAt") {
                self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
            }
            if data.keys.contains("updatedAt") {
                self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
            }
            if !snapshot.metadata.isFromCache {
                DocumentCache.shared.set(key: snapshot.reference.path, data: data)
            }
        } catch (let error) {
            print(error)
            return nil
        }
    }

    subscript<T: Any>(keyPath: WritableKeyPath<Model, T>) -> T? {
        get {
            return self.data?[keyPath: keyPath]
        }
        set {
            self.data?[keyPath: keyPath] = newValue!
        }
    }
}

public extension DataRepresentable where Self: Object {

    func save(completion: ((Error?) -> Void)? = nil) {
        self.save(reference: nil, completion: completion)
    }

    func update(completion: ((Error?) -> Void)? = nil) {
        self.update(reference: nil, completion: completion)
    }

    func delete(completion: ((Error?) -> Void)? = nil) {
        self.delete(reference: nil, completion: completion)
    }

    func save(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.save(document: self, reference: reference)
        batch.commit(completion)
    }

    func update(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.update(document: self, reference: reference)
        batch.commit(completion)
    }

    func delete(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.delete(document: self, reference: reference)
        batch.commit(completion)
    }
}

// MARK: -

public extension DataRepresentable where Self: Object {

    static func get(documentReference: DocumentReference, source: FirestoreSource = FirestoreSource.default, completion: @escaping ((Self?, Error?) -> Void)) {
        documentReference.getDocument(source: source) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, DocumentError.invalidData)
                return
            }
            guard let document: Self = Self(snapshot: snapshot) else {
                completion(nil, DocumentError.invalidData)
                return
            }
            completion(document, nil)
        }
    }

    static func get(id: String, source: FirestoreSource = FirestoreSource.default, completion: @escaping ((Self?, Error?) -> Void)) {
        let documentReference: DocumentReference = Self.init(id: id).documentReference
        self.get(documentReference: documentReference, source: source, completion: completion)
    }

    static func listen(id: String, includeMetadataChanges: Bool = true, completion: @escaping ((Self?, Error?) -> Void)) -> Disposer {
        let listenr: ListenerRegistration = Self.collectionReference.document(id).addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let document: Self = Self(snapshot: snapshot!) else {
                completion(nil, DocumentError.invalidData)
                return
            }
            completion(document, nil)
        }
        return Disposer(.value(listenr))
    }
}
