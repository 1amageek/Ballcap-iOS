//
//  DataCacheable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore


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

    func get(_ completion: @escaping (Self?, Error?) -> Void) {
        if self.cache != nil {
            self.data = self.cache
            if Thread.isMainThread {
                completion(self, nil)
            } else {
                DispatchQueue.main.async {
                    completion(self, nil)
                }
            }
        } else {
            Self.get(documentReference: self.documentReference, source: .cache) { (object, error) in
                if let object: Self = object {
                    self.data = object.data
                    completion(object, error)
                } else {
                    Self.get(documentReference: self.documentReference, source: .server) { (object, error) in
                        self.data = object?.data
                        completion(object, error)
                    }
                }
            }
        }
    }
}
