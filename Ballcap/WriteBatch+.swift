//
//  WriteBatch+.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/01.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public extension WriteBatch {

    @discardableResult
    func save<T: Encodable>(document: Document<T>, reference: DocumentReference? = nil) -> WriteBatch {
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data: [String: Any] = try Firestore.Encoder().encode(document.data!)
            if document.isIncludedInTimestamp {
                data["createdAt"] = FieldValue.serverTimestamp()
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            return self.setData(data, forDocument: reference)
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    func update<T: Encodable>(document: Document<T>, reference: DocumentReference? = nil) -> WriteBatch {
        let reference: DocumentReference = reference ?? document.documentReference
        do {
            var data = try Firestore.Encoder().encode(document.data!)
            if document.isIncludedInTimestamp {
                data["updatedAt"] = FieldValue.serverTimestamp()
            }
            return self.updateData(data, forDocument: reference)
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    func delete<T: Encodable>(document: Document<T>) -> WriteBatch {
        return self.deleteDocument(document.documentReference)
    }
}

