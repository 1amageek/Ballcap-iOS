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
