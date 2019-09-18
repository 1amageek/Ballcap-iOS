//
//  Documentable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public protocol Documentable: class, Referencable & Equatable {

    var id: String { get }

    var path: String { get }

    var documentReference: DocumentReference! { get }

    var storageReference: StorageReference { get }

    var shouldIncludedInTimestamp: Bool { get }

    var createdAt: Timestamp { get }

    var updatedAt: Timestamp { get }

    init(_ documentReference: DocumentReference)
}

public extension Documentable {

    var id: String { return self.documentReference.documentID }

    var path: String { return self.documentReference.path }

    var shouldIncludedInTimestamp: Bool { return true }
}
