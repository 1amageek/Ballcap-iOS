//
//  HierarchicalStructurable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public protocol HierarchicalStructurable {

    associatedtype CollectionKeys: RawRepresentable
}

public extension HierarchicalStructurable where Self: Object, Self.CollectionKeys.RawValue == String {

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

public extension HierarchicalStructurable where Self: Object, Self: DataRepresentable, Self.CollectionKeys.RawValue == String {

    init() {
        self.init(Self.collectionReference.document())
    }

    init(collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document())
        self.data = Model()
    }

    init(id: String, collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Self.collectionReference
        self.init(collectionReference.document(id))
        self.data = Model()
    }

    func collection(path: Self.CollectionKeys) -> CollectionReference {
        return self.documentReference.collection(path.rawValue)
    }

    func collection<T: Object>(path: Self.CollectionKeys) -> DataSource<T>.Query where T: DataRepresentable {
        let collectionReference: CollectionReference = self.collection(path: path)
        return DataSource.Query(collectionReference)
    }
}

extension CollectionReference {

    func child<T: Object>(type: Object.Type) -> T {
        return T.init(self.document())
    }

    func child<T: Object>(id: String, type: Object.Type) -> T {
        return T.init(self.document(id))
    }
}
