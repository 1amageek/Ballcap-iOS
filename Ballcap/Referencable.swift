//
//  Referencable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol Referencable {

    static var modelVersion: String { get }

    static var modelName: String { get }

    static var path: String { get }

    static var collectionReference: CollectionReference { get }
}
