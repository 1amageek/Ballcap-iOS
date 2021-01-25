//
//  DataRepresentable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

public protocol DataRepresentable: class, Hashable {

    associatedtype Model: Modelable & Codable

    var data: Model? { get set }

    init()
}

public enum CachePolicy {
    case cacheOnly
    case serverOnly
    case cacheElseServer
    case serverElseCache
    case cacheThenServer
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

    init(id: String, from data: Model, collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document(id))
        self.data = data
    }

    init(documentReference: DocumentReference, from data: [String: Any]) throws {
        self.init(documentReference)
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
            throw error
        }
    }

    init(documentReference: DocumentReference, from data: Model) {
        self.init(documentReference)
        self.data = data
    }

    init(snapshot: DocumentSnapshot) throws {
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
            DocumentCache.shared.set(key: snapshot.reference.path, data: data)
        } catch (let error) {
            print(error)
            throw error
        }
    }

    internal func _set(snapshot: DocumentSnapshot) throws {
        self.snapshot = snapshot
        guard let data: [String: Any] = snapshot.data() else {
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
            DocumentCache.shared.set(key: snapshot.reference.path, data: data)
        } catch (let error) {
            throw error
        }
    }

    subscript<T: Any>(keyPath: WritableKeyPath<Model, T>) -> T {
        get {
            guard let data = self.data else {
                fatalError("[Ballcap: DataRepresentable] This object has not data.")
            }
            return data[keyPath: keyPath]
        }
        set {
            self.data![keyPath: keyPath] = newValue
        }
    }

    func copy() -> Self {
        let copySelf: Self = Self.init(self.documentReference)
        copySelf.data = self.data
        return copySelf
    }

    var description: String {
        let base: String =
            "  path: \(self.path)\n" +
                "  createdAt: \(self.createdAt) (\(self.createdAt.dateValue()))\n" +
        "  updatedAt: \(self.updatedAt) (\(self.updatedAt.dateValue()))\n"

        if let data = self.data {
            let mirror = Mirror(reflecting: data)
            let values: String = mirror.children.reduce(base) { (result, child) -> String in
                guard let label: String = child.label else { return result }
                return result + "  \(label): \(String(describing: child.value))\n"
            }
            return "\(type(of: self).name) {\n\(values)}"
        }

        return "\(type(of: self).name) {\n data: nil\n}"
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
        batch.save(self, reference: reference)
        batch.commit(completion)
    }

    func update(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.update(self, reference: reference)
        batch.commit(completion)
    }

    func delete(reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let batch: Batch = Batch()
        batch.delete(self, reference: reference)
        batch.commit(completion)
    }

    func merge(reference: DocumentReference? = nil, data: [String: Any], completion: ((Error?) -> Void)? = nil) {
        let reference: DocumentReference = reference ?? self.documentReference
        let batch: Batch = Batch()
        batch.set(data, reference: reference)
        batch.commit(completion)
    }
}

// MARK: -

public extension DataRepresentable where Self: Object {
    
    func get(_ cachePolicy: CachePolicy = .cacheElseServer, completion: ((Self?, Error?) -> Void)? = nil) -> Self {
        switch cachePolicy {
            case .cacheOnly:
                Self.get(documentReference: self.documentReference, source: .cache) { (object, error) in
                    if self.data != object?.data {
                        self.data = object?.data
                    }
                    completion?(object, error)
            }
            case .serverOnly:
                Self.get(documentReference: self.documentReference, source: .server) { (object, error) in
                    if self.data != object?.data {
                        self.data = object?.data
                    }
                    completion?(object, error)
            }
            case .cacheElseServer:
                Self.get(documentReference: self.documentReference, source: .cache) { (object, error) in

                    // Decoding Error Handling
                    // Schema may be changed and coding with cached data may not be possible.
                    if let _ = error as? DecodingError {
                        Self.get(documentReference: self.documentReference, source: .server) { (object, error) in
                            if self.data != object?.data {
                                self.data = object?.data
                            }
                            completion?(object, error)
                        }
                        return
                    }

                    if let object: Self = object {
                        if self.data != object.data {
                            self.data = object.data
                        }
                        completion?(object, error)
                    } else {
                        Self.get(documentReference: self.documentReference, source: .server) { (object, error) in
                            if self.data != object?.data {
                                self.data = object?.data
                            }
                            completion?(object, error)
                        }
                    }
            }
            case .serverElseCache:
                Self.get(documentReference: self.documentReference, source: .default) { (object, error) in
                    if self.data != object?.data {
                        self.data = object?.data
                    }
                    completion?(object, error)
            }
            case .cacheThenServer:
                Self.get(documentReference: self.documentReference, source: .cache) { (object, error) in
                    if self.data != object?.data {
                        self.data = object?.data
                    }
                    completion?(object, error)
                }
                Self.get(documentReference: self.documentReference, source: .server) { (object, error) in
                    if self.data != object?.data {
                        self.data = object?.data
                    }
                    completion?(object, error)
            }
        }
        return self
    }
    
    // MARK: -

    static func get(documentReference: DocumentReference, source: FirestoreSource = FirestoreSource.default, completion: @escaping ((Self?, Error?) -> Void)) {
        documentReference.getDocument(source: source) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }
            do {
                let document: Self = try Self(snapshot: snapshot)
                completion(document, nil)
            } catch(let error) {
                completion(nil, error)
            }
        }
    }

    static func get(id: String, source: FirestoreSource = FirestoreSource.default, completion: @escaping ((Self?, Error?) -> Void)) {
        let documentReference: DocumentReference = Self.init(id: id).documentReference
        self.get(documentReference: documentReference, source: source, completion: completion)
    }

    static func listen(documentReference: DocumentReference, includeMetadataChanges: Bool = true, completion: @escaping ((Self?, Error?) -> Void)) -> Disposer {
        let listenr: ListenerRegistration = documentReference.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }
            do {
                let document: Self = try Self(snapshot: snapshot)
                completion(document, nil)
            } catch(let error) {
                completion(nil, error)
            }
        }
        return Disposer(.value(listenr))
    }

    static func listen(id: String, includeMetadataChanges: Bool = true, completion: @escaping ((Self?, Error?) -> Void)) -> Disposer {
        return self.listen(documentReference: Self.collectionReference.document(id), includeMetadataChanges: includeMetadataChanges, completion: completion)
    }

    func listen(includeMetadataChanges: Bool = true, completion: @escaping ((Self?, Error?) -> Void)) -> Disposer {
        let document: Self = self
        let listenr: ListenerRegistration = self.documentReference.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }
            do {
                try document._set(snapshot: snapshot)
                completion(document, nil)
            } catch (let error) {
                completion(nil, error)
            }
        }
        return Disposer(.value(listenr))
    }
}
