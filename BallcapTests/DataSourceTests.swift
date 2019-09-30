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

    func testDataSource() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        struct Model: Codable, Modelable, Equatable {
            static var name: String { "datasource" }
            var id: String = ""
        }

        let a: Document<Model> = Document()
        a[\.id] = "a"
        let b: Document<Model> = Document()
        b[\.id] = "b"

        let batch: Batch = Batch()
        batch.save(a)
        batch.save(b)
        batch.commit { _ in
            Document<Model>.order(by: "id").get { (snapshot, _) in
                XCTAssertEqual(snapshot?.documents.count, 2)
                XCTAssertEqual(snapshot?.documents[0].data()["id"] as! String, "a")
                XCTAssertEqual(snapshot?.documents[1].data()["id"] as! String, "b")
                let batch: Batch = Batch()
                batch.delete(a)
                batch.delete(b)
                batch.commit { _ in
                    Document<Model>.order(by: "id").get { (snapshot, _) in
                        XCTAssertEqual(snapshot?.documents.count, 0)
                        exp.fulfill()
                    }
                }
            }
        }

        self.wait(for: [exp], timeout: 30)
    }
}
