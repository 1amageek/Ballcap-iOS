//
//  Store.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public final class Store {

    static let shared: Store = Store()

    lazy var cache: NSCache<NSString, NSDictionary> = {
        let cache: NSCache<NSString, NSDictionary> = NSCache()
        return cache
    }()

    func get<T: Document<U>, U: Codable>(documentType: T.Type, id: String) -> T? {
        guard let data: NSDictionary = self.cache.object(forKey: id as NSString) else {
            return nil
        }
        return documentType.init(id: id, from: data as! [String : Any])
    }

    func set<T: Document<U>, U: Codable>(_ document: T, reference: DocumentReference? = nil, completion: ((Error?) -> Void)? = nil) {
        let reference: DocumentReference = reference ?? document.documentReference
        let data: [String: Any] = try! Firestore.Encoder().encode(document.data)
        reference.setData(data, merge: true, completion: completion)
    }

}
