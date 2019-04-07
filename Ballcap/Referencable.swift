//
//  Referencable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol Referencable: Equatable {

    static var modelVersion: String { get }

    static var modelName: String { get }

    static var path: String { get }

    static var collectionReference: CollectionReference { get }

    static var documentReference: DocumentReference { get }
}

public extension Referencable {

    static var modelVersion: String {
        return "1"
    }

    static var modelName: String {
        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
    }

    static var path: String {
        return "version/\(self.modelVersion)/\(self.modelName)"
    }

    static var collectionReference: CollectionReference {
        return Firestore.firestore().collection(self.path)
    }

    static var documentReference: DocumentReference {
        return Firestore.firestore().document("version/\(self.modelVersion)")
    }
}
