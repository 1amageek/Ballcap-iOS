//
//  HierarchicalStructurableTests.swfit
//  BallcapTests
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

class HierarchicalStructurableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

        func testHierarchicalStructurable() {
            struct Model: Codable, Modelable {}
            class Obj: Object, HierarchicalStructurable {
                enum CollectionKeys: String {
                    case subCollectionPath
                }
            }
            let obj: Obj = Obj(id: "a")
            XCTAssertEqual(obj.collection(path: .subCollectionPath).path, "version/1/obj/a/subCollectionPath")
        }

    // TODO: Query tests
}
