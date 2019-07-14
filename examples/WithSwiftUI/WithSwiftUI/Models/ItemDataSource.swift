//
//  ItemDataSource.swift
//  LiveCoding00
//
//  Created by 1amageek on 2019/07/04.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import Ballcap
import Firebase
import SwiftUI
import Combine

class ItemDatabase: BindableObject {

    var didChange = PassthroughSubject<Void, Never>()

    var _dataSource: DataSource<Document<Item>>?

    var items: [Document<Item>] = [] {
        didSet { self.didChange.send() }
    }

    init() {
        _dataSource = DataSource<Document<Item>>.Query(Document<Item>.collectionReference).dataSource()
            .onCompleted({ [weak self] (_, items) in
                self?.items = items
            }).listen()
    }
}
