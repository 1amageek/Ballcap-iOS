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

    func testHierarchicalStructurableDataSource() {
        struct aModel: Codable, Modelable {}
        class Obj: Object, HierarchicalStructurable, DataRepresentable {
            typealias Model = aModel

            var data: Model?

            enum CollectionKeys: String {
                case subCollectionPath
            }
        }
        let obj: Obj = Obj(id: "a")
        let d: DataSource<Obj>.Query = obj.collection(path: .subCollectionPath)
        XCTAssertEqual(d.reference.path, "version/1/obj/a/subCollectionPath")
    }

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
        XCTAssertEqual(child.documentReference.path, "version/1/parent/a/child/b")
        XCTAssertEqual(child.collection(path: .subCollectionPath).path, "version/1/parent/a/child/b/subCollectionPath")
    }

    // TODO: Query tests
}
