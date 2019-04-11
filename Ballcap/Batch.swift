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

    private var _deleteCacheStorage: [String] = []

    private var _isCommitted: Bool = false

    public init(firestore: Firestore = Firestore.firestore()) {
        self._writeBatch = firestore.batch()
    }

    @discardableResult
    public func save<T: Documentable>(document: T, reference: DocumentReference? = nil) -> Self where T: DataRepresentable {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data: [String: Any] = try Firestore.Encoder().encode(document.data!)
            if document.shouldIncludedInTimestamp {
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self._writeBatch.setData(data, forDocument: reference)
            return self
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    public func update<T: Documentable>(document: T, reference: DocumentReference? = nil) -> Self where T: DataRepresentable {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data = try Firestore.Encoder().encode(document.data!)
            if document.shouldIncludedInTimestamp {
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self._writeBatch.updateData(data, forDocument: reference)
            return self
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    public func delete<T: Documentable>(document: T, reference: DocumentReference? = nil) -> Self {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        let reference: DocumentReference = reference ?? document.documentReference
        self._writeBatch.deleteDocument(reference)
        self._deleteCacheStorage.append(reference.path)
        return self
    }

    public func commit(_ completion: ((Error?) -> Void)? = nil) {
        if _isCommitted {
            fatalError("Batch is already committed")
        }
        self._writeBatch.commit {(error) in
            if let error = error {
                completion?(error)
                return
            }
            self._deleteCacheStorage.forEach({ (key) in
                DocumentCache.shared.delete(key: key)
            })
            completion?(nil)
        }
    }
}

