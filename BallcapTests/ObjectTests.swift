//
//  ObjectTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
//@testable import Ballcap


class ObjectTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
        BallcapApp.configure(Firestore.firestore().document("version/1"))
    }

    func testObjectID() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj(id: "a")
        XCTAssertEqual(o.documentReference.path, "version/1/obj/a")
    }

    func testObjectIDFromDatae() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj(id: "a", from: [:])!
        XCTAssertEqual(o.documentReference.path, "version/1/obj/a")
    }

//    func testObjectIDFromModel() {
//        class Obj: Object, DataRepresentable {
//            struct Model: Modelable & Codable { }
//            var data: Model?
//        }
//        let o: Obj = Obj(id: "a", from: Obj.Model())
//        XCTAssertEqual(o.documentReference.path, "version/1/obj/a")
//    }

    func testObjectIDOtherCollectionReference() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj(id: "a", collectionReference: Firestore.firestore().collection("a"))
        XCTAssertEqual(o.documentReference.path, "a/a")
    }

    func testObjectIDFromDataOtherCollectionReference() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj(id: "a", from: [:], collectionReference: Firestore.firestore().collection("a"))!
        XCTAssertEqual(o.documentReference.path, "a/a")
    }
//
//    func testObjectIDFromModelOtherCollectionReference() {
//        struct Model: Codable, Modelable, Equatable {}
//        let d: Object<Model> = Object(id: "a", from: Model(), collectionReference: Firestore.firestore().collection("a"))
//        XCTAssertEqual(d.documentReference.path, "a/a")
//    }
//
    func testObjectKeyPath() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable & Equatable {
                var path: String = "a"
            }
            var data: Model?
        }
        let o: Obj = Obj(id: "a")
        XCTAssertEqual(o[\.path], "a")
    }

    func testObjectSaveUpdateDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable & Equatable {
                var a: String = "a"
            }
            var data: Model?
        }
        let d: Obj = Obj(id: "a")
        d[\.a] = "t"
        d.save() { _ in
            Obj.get(id: "a", completion: { (doc, _) in
                XCTAssertEqual(doc!.data!.a, "t")
                doc![\.a] = "s"
                doc?.update() { _ in
                    Obj.get(id: "a", completion: { (doc, _) in
                        XCTAssertEqual(doc!.data!.a, "s")
                        doc?.delete() { _ in
                            Obj.get(id: "a", completion: { (doc, _) in
                                XCTAssertNil(doc)
                                exp.fulfill()
                            })
                        }
                    })
                }
            })
        }
        self.wait(for: [exp], timeout: 30)
    }
}
