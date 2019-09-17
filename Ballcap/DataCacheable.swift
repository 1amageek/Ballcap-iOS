//
//  DataCacheable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public enum DataCacheableError: Error {
  case serverValueHasNotBeenDetermined
}

public protocol DataCacheable: class {

    associatedtype Model: Modelable & Codable

    var cache: Model? { get }
}

public extension DataCacheable where Self: Object {

    var cache: Model? {
        do {
            return try DocumentCache.shared.get(modelType: Model.self, reference: self.documentReference)
        } catch {
            return nil
        }
    }
}

public extension DataCacheable where Self: Object, Self: DataRepresentable {

    @discardableResult
    func get(_ completion: ((Self?, Error?) -> Void)? = nil) -> Self {
        if let data: [String: Any] = DocumentCache.shared.get(reference: self.documentReference) {
            do {
                self.data = try Firestore.Decoder().decode(Model.self, from: data)
                if data.keys.contains("createdAt") {
                    if let createdAt: Timestamp = data["createdAt"] as? Timestamp {
                        self.createdAt = createdAt
                    } else {
                        throw DataCacheableError.serverValueHasNotBeenDetermined
                    }
                }
                if data.keys.contains("updatedAt") {
                    if let updatedAt: Timestamp = data["updatedAt"] as? Timestamp {
                        self.updatedAt = updatedAt
                    } else {
                        throw DataCacheableError.serverValueHasNotBeenDetermined
                    }
                }
                if Thread.isMainThread {
                    completion?(self, nil)
                } else {
                    DispatchQueue.main.async {
                        completion?(self, nil)
                    }
                }
            } catch {
                Self.get(documentReference: self.documentReference, source: .cache) { (object, error) in
                    if let object: Self = object {
                        self.data = object.data
                        completion?(object, error)
                    } else {
                        Self.get(documentReference: self.documentReference, source: .server) { (object, error) in
                            self.data = object?.data
                            completion?(object, error)
                        }
                    }
                }
            }
        } else {
            Self.get(documentReference: self.documentReference, source: .cache) { (object, error) in
                if let object: Self = object {
                    self.data = object.data
                    completion?(object, error)
                } else {
                    Self.get(documentReference: self.documentReference, source: .server) { (object, error) in
                        self.data = object?.data
                        completion?(object, error)
                    }
                }
            }
        }
        return self
    }
}
