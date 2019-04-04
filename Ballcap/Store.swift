//
//  Store.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

internal final class Store {

    static let shared: Store = Store()

    lazy var cache: NSCache<NSString, NSDictionary> = {
        let cache: NSCache<NSString, NSDictionary> = NSCache()
        return cache
    }()

    func get<T: Document<U>, U: Codable>(documentType: T.Type, reference: DocumentReference) -> T? {
        guard let data: NSDictionary = self.cache.object(forKey: reference.path as NSString) else {
            return nil
        }
        return documentType.init(id: reference.documentID, from: data as! [String : Any], collectionReference: reference.parent)
    }

    func set<T: Document<U>, U: Codable & Documentable>(_ document: T, reference: DocumentReference? = nil) throws {
        do {
            let data: [String: Any] = try Firestore.Encoder().encode(document.data)
            let reference: DocumentReference = reference ?? document.documentReference
            self.set(key: reference.path, data: data)
        } catch (let error) {
            throw error
        }
    }

    func set(key: String, data: [String: Any]) {
        self.cache.setObject(data as NSDictionary, forKey: key as NSString)
    }
}
