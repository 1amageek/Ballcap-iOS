//
//  Documentable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public protocol Documentable: Referencable {

    var id: String { get }

    var path: String { get }

    var documentReference: DocumentReference! { get }

    var shouldIncludedInTimestamp: Bool { get }

    var createdAt: Timestamp { get }

    var updatedAt: Timestamp { get }
}

public extension Documentable {

    var id: String { return self.documentReference.documentID }

    var path: String { return self.documentReference.path }

    var shouldIncludedInTimestamp: Bool { return true }
}
