//
//  Batch.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/01.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public final class Batch {

    private var _writeBatch: FirebaseFirestore.WriteBatch

    private var _updateCacheStorage: [String: [String: Any]] = [:]

    private var _deleteCacheStorage: [String] = []

    public init(firestore: Firestore = Firestore.firestore()) {
        self._writeBatch = firestore.batch()
    }

    @discardableResult
    public func set(_ data: [String: Any], reference: DocumentReference) -> Self {
        self._writeBatch.setData(data, forDocument: reference, merge: true)
        return self
    }

    // MARK: -

    @discardableResult
    public func save<T: Documentable>(_ document: T, reference: DocumentReference? = nil, merge: Bool = false) -> Self where T: DataRepresentable {
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data: [String: Any] = try Firestore.Encoder().encode(document.data!)
            if document.shouldIncludedInTimestamp {
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self._writeBatch.setData(data, forDocument: reference, merge: merge)
            self._updateCacheStorage[reference.path] = data
            return self
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    public func update<T: Documentable>(_ document: T, reference: DocumentReference? = nil) -> Self where T: DataRepresentable {
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data = try Firestore.Encoder().encode(document.data!)
            if document.shouldIncludedInTimestamp {
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self._writeBatch.updateData(data, forDocument: reference)
            self._updateCacheStorage[reference.path] = data
            return self
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    public func delete<T: Documentable>(_ document: T, reference: DocumentReference? = nil) -> Self {
        let reference: DocumentReference = reference ?? document.documentReference
        self._writeBatch.deleteDocument(reference)
        self._deleteCacheStorage.append(reference.path)
        return self
    }

    // MARK: -

    @discardableResult
    public func save<T: Documentable>(_ document: T, to collectionReference: CollectionReference) -> Self where T: DataRepresentable {
        let reference: DocumentReference = collectionReference.document(document.id)
        self.save(document, reference: reference)
        return self
    }

    @discardableResult
    public func update<T: Documentable>(_ document: T, in collectionReference: CollectionReference) -> Self where T: DataRepresentable {
        let reference: DocumentReference = collectionReference.document(document.id)
        self.update(document, reference: reference)
        return self
    }

    @discardableResult
    public func delete<T: Documentable>(_ document: T, in collectionReference: CollectionReference) -> Self {
        let reference: DocumentReference = collectionReference.document(document.id)
        self.delete(document, reference: reference)
        return self
    }

    @discardableResult
    public func save<T: Documentable>(_ documents: [T], to collectionReference: CollectionReference) -> Self where T: DataRepresentable {
        documents.forEach { (document) in
            let reference: DocumentReference = collectionReference.document(document.id)
            self.save(document, reference: reference)
        }
        return self
    }

    @discardableResult
    public func update<T: Documentable>(_ documents: [T], in collectionReference: CollectionReference) -> Self where T: DataRepresentable {
        documents.forEach { (document) in
            let reference: DocumentReference = collectionReference.document(document.id)
            self.update(document, reference: reference)
        }
        return self
    }

    @discardableResult
    public func delete<T: Documentable>(_ documents: [T], in collectionReference: CollectionReference) -> Self {
        documents.forEach { (document) in
            let reference: DocumentReference = collectionReference.document(document.id)
            self.delete(document, reference: reference)
        }
        return self
    }

    public func commit(_ completion: ((Error?) -> Void)? = nil) {
        self._writeBatch.commit {(error) in
            if let error = error {
                completion?(error)
                return
            }
            self._updateCacheStorage.forEach { DocumentCache.shared.set(key: $0, data: $1) }
            self._deleteCacheStorage.forEach { DocumentCache.shared.delete(key: $0) }
            completion?(nil)
        }
    }
}
