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
    func set<T: Encodable>(document: Document<T>) -> WriteBatch {
        do {
            let data = try Firestore.Encoder().encode(document.data!)
            return self.setData(data, forDocument: document.documentReference, merge: true)
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    func update<T: Encodable>(document: Document<T>) -> WriteBatch {
        do {
            let data = try Firestore.Encoder().encode(document.data!)
            return self.updateData(data, forDocument: document.documentReference)
        } catch let error {
            fatalError("Unable to encode data with Firestore encoder: \(error)")
        }
    }

    @discardableResult
    func delete<T: Encodable>(document: Document<T>) -> WriteBatch {
        return self.deleteDocument(document.documentReference)
    }
}

