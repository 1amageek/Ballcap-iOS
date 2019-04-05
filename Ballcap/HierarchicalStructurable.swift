//
//  HierarchicalStructurable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

protocol HierarchicalStructurable {

    associatedtype CollectionKeys: RawRepresentable
}


extension HierarchicalStructurable where Self: Object, Self.CollectionKeys.RawValue == String {

    init() {
        self.init(Self.collectionReference.document())
    }

    init(collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document())
    }

    init(id: String, collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document(id))
    }

    func collection(path: Self.CollectionKeys) -> CollectionReference {
        return self.documentReference.collection(path.rawValue)
    }

    func collection<T: Object>(path: Self.CollectionKeys) -> DataSource<T>.Query where T: DataRepresentable {
        let collectionReference: CollectionReference = self.collection(path: path)
        return DataSource.Query(collectionReference)
    }
}
