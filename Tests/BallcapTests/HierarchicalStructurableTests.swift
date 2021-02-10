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
@testable import Ballcap

class HierarchicalStructurableTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testDataRepresentableHierarchicalStructurable() {
        struct Model: Codable, Modelable {}
        class Obj: Object, DataRepresentable, HierarchicalStructurable {
            var data: Obj.Model?
            struct Model: Modelable & Codable {

            }
            enum CollectionKeys: String {
                case subCollectionPath
            }
        }
        let a: Obj = Obj()
        let b: Obj = Obj(id: "a")
        XCTAssertNotNil(a.data)
        XCTAssertNotNil(b.data)
        XCTAssertEqual(b.collection(path: .subCollectionPath).path, "obj/a/subCollectionPath")
    }

    func testHierarchicalStructurable() {
        struct Model: Codable, Modelable {}
        class Obj: Object, HierarchicalStructurable {
            enum CollectionKeys: String {
                case subCollectionPath
            }
        }
        let obj: Obj = Obj(id: "a")
        XCTAssertEqual(obj.collection(path: .subCollectionPath).path, "obj/a/subCollectionPath")
    }

//    func testHierarchicalStructurableDataSource() {
//        struct aModel: Codable, Modelable {}
//        class Obj: Object, HierarchicalStructurable, DataRepresentable {
//            typealias Model = aModel
//
//            var data: Model?
//
//            enum CollectionKeys: String {
//                case subCollectionPath
//            }
//        }
//        let obj: Obj = Obj(id: "a")
//        let d: DataSource<Obj>.Query = obj.collection(path: .subCollectionPath)
//        XCTAssertEqual(d.query.path, "obj/a/subCollectionPath")
//    }

    func testNestedStructurable() {
        struct Model: Codable, Modelable {}
        class Parent: Object, HierarchicalStructurable {
            enum CollectionKeys: String {
                case child
            }
        }
        class Child: Object, HierarchicalStructurable {
            enum CollectionKeys: String {
                case subCollectionPath
            }
        }
        let parent: Parent = Parent(id: "a")
        let child: Child = parent.collection(path: .child).child(id: "b", type: Child.self)
        XCTAssertEqual(child.documentReference.path, "parent/a/child/b")
        XCTAssertEqual(child.collection(path: .subCollectionPath).path, "parent/a/child/b/subCollectionPath")
    }

    // TODO: Query tests
}
