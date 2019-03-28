//
//  Store.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

final class Store {

    static func set<T: Document & Codable>(_ doc: T, reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let reference: DocumentReference = reference ?? doc.reference
        let data: [String: Any] = try! Firestore.Encoder().encode(doc)
        reference.setData(data, merge: true, completion: completion)
    }
}
