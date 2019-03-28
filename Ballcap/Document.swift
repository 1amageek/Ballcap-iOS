//
//  Document.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public protocol Document: Referencable {

    init()

    init(id: String)
}

public extension Document where Self: Codable {

    func save() {
        Store.set(self)
    }

    func update() {
        Store.set(self)
    }
}
