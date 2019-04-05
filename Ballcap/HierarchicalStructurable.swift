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


extension HierarchicalStructurable where Self: Document, Self.CollectionKeys.RawValue == String {

    func collection<T: Document>(path: Self.CollectionKeys) -> DataSource<T>.Query where T: DataRepresentable {
        let collectionReference: CollectionReference = self.documentReference.collection(path.rawValue)
        return DataSource.Query(collectionReference)
    }
}
