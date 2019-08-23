//
//  DocumentCache.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

internal final class DocumentCache {

    static let shared: DocumentCache = DocumentCache()

    lazy var cache: NSCache<NSString, NSDictionary> = {
        let cache: NSCache<NSString, NSDictionary> = NSCache()
        cache.countLimit = 1000
        return cache
    }()

    func get(reference: DocumentReference) -> [String: Any]? {
        return self.cache.object(forKey: reference.path as NSString) as? [String: Any]
    }

    func get<T: Document<U>, U: Modelable & Codable>(documentType: T.Type, reference: DocumentReference) -> T? {
        guard let data: [String: Any] = self.cache.object(forKey: reference.path as NSString) as? [String: Any] else { return nil }
        return Document<U>.init(id: reference.documentID, from: data) as? T
    }

    func get<T: Object>(documentType: T.Type, reference: DocumentReference) -> T? where T: DataRepresentable {
        guard let data: [String: Any] = self.cache.object(forKey: reference.path as NSString) as? [String: Any] else { return nil }
        return documentType.init(id: reference.documentID, from: data)
    }

    func get<T: Codable & Modelable>(modelType: T.Type, reference: DocumentReference) throws -> T? {
        return try self.get(modelType: modelType, path: reference.path)
    }

    func get<T: Codable & Modelable>(modelType: T.Type, path: String) throws -> T? {
        guard let data: [String: Any] = self.cache.object(forKey: path as NSString) as? [String: Any] else { return nil }
        do {
            let document: T = try Firestore.Decoder().decode(T.self, from: data)
            return document
        } catch (let error) {
            throw error
        }
    }

    func set<T: DataRepresentable & Documentable>(_ document: T, reference: DocumentReference? = nil) throws {
        do {
            var data: [String: Any] = try Firestore.Encoder().encode(document.data)
            data["createdAt"] = document.createdAt
            data["updatedAt"] = document.updatedAt
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

    func clear() {
        self.cache.removeAllObjects()
    }
}
