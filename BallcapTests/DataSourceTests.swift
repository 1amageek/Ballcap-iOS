//
//  DataSourceTests.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/02.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

class DataSourceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testSortDesc() {
        struct Model: Codable, Modelable, Equatable {}
        let a: Document<Model> = Document()
        let b: Document<Model> = Document()
        let array: [Document<Model>] = [a, b]
        let areInIncreasingOrder: (Document<Model>, Document<Model>) throws -> Bool = { l, r in
            return true
        }
        let sorted = try! array.sorted(by: areInIncreasingOrder)
        XCTAssertEqual(sorted, [b, a])
    }

    func testSortAesc() {
        struct Model: Codable, Modelable, Equatable {}
        let a: Document<Model> = Document()
        let b: Document<Model> = Document()
        let array: [Document<Model>] = [a, b]
        let areInIncreasingOrder: (Document<Model>, Document<Model>) throws -> Bool = { l, r in
            return false
        }
        let sorted = try! array.sorted(by: areInIncreasingOrder)
        XCTAssertEqual(sorted, [a, b])
    }
}
