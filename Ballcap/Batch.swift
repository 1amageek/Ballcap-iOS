//
//  Batch.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/01.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public final class Batch {

    private var writeBatch: FirebaseFirestore.WriteBatch

    private var storage: [String: [String: Any]] = [:]

    private var isCommitted: Bool = false

    public init(firestore: Firestore = Firestore.firestore()) {
        self.writeBatch = firestore.batch()
    }

    @discardableResult
    public func save<T: Encodable>(document: Document<T>, reference: DocumentReference? = nil) -> Self {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data: [String: Any] = try Firestore.Encoder().encode(document.data!)
            if document.isIncludedInTimestamp {
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self.storage[reference.path] = data
            self.writeBatch.setData(data, forDocument: reference)
            return self
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    public func update<T: Encodable>(document: Document<T>, reference: DocumentReference? = nil) -> Self {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data = try Firestore.Encoder().encode(document.data!)
            if document.isIncludedInTimestamp {
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            self.storage[reference.path] = data
            self.writeBatch.updateData(data, forDocument: reference)
            return self
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    public func delete<T: Encodable>(document: Document<T>) -> WriteBatch {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        return self.writeBatch.deleteDocument(document.documentReference)
    }

    public func commit(_ completion: ((Error?) -> Void)? = nil) {
        if isCommitted {
            fatalError("Batch is already committed")
        }
        self.writeBatch.commit { [weak self] (error) in
            if let error = error {
                completion?(error)
                return
            }
            self?.storage.forEach({ key, data in
                Store.shared.set(key: key, data: data)
            })
            self?.storage = [:]
            completion?(nil)
        }
    }
}

