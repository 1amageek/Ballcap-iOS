//
//  Store.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

internal final class FStore {
    
    static let shared: Store = Store()
    
    lazy var cache: NSCache<NSString, NSDictionary> = {
        let cache: NSCache<NSString, NSDictionary> = NSCache()
        return cache
    }()

    func get<T: Document<U>, U: Modelable & Codable>(documentType: T.Type, reference: DocumentReference) -> T? {
        guard let data: [String: Any] = self.cache.object(forKey: reference.path as NSString) as? [String: Any] else { return nil }
        return Document<U>.init(id: reference.documentID, from: data) as? T
    }
    
    func get<T: Object>(documentType: T.Type, reference: DocumentReference) -> T? where T: DataRepresentable {
        guard let data: [String: Any] = self.cache.object(forKey: reference.path as NSString) as? [String: Any] else { return nil }
        return documentType.init(id: reference.documentID, from: data)
    }
    
    func get<T: Codable & Modelable>(modelType: T.Type, reference: DocumentReference) throws -> T? {
        guard let data: [String: Any] = self.cache.object(forKey: reference.path as NSString) as? [String: Any] else { return nil }
        do {
            let document: T = try Firestore.Decoder().decode(T.self, from: data)
            return document
        } catch (let error) {
            throw error
        }
    }
    
    func set<T: DataRepresentable & Documentable>(_ document: T, reference: DocumentReference? = nil) throws {
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

    func delete(reference: DocumentReference) {
        self.delete(key: reference.path)
    }

    func delete(key: String) {
        self.cache.removeObject(forKey: key as NSString)
    }
}
