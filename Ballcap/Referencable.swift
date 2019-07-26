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

    static var name: String { get }

    static var path: String { get }

    static var collectionReference: CollectionReference { get }

    static var parent: DocumentReference? { get }
}

public extension Referencable {

    static var path: String {
        return self.collectionReference.path
    }

    static var collectionReference: CollectionReference {
        return BallcapApp.default.rootReference?.collection(self.name) ?? Firestore.firestore().collection(self.name)
    }

    static var parent: DocumentReference? {
        return self.collectionReference.parent
    }
}
