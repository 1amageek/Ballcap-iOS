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

    func testObjectAutoID() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj()
        XCTAssertEqual(o.documentReference.parent.path, "version/1/obj")
        XCTAssertEqual(o.documentReference.path, "version/1/obj/\(o.id)")
    }

    func testObjectID() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj(id: "a")
        XCTAssertEqual(o.documentReference.path, "version/1/obj/a")
    }

    func testObjectIDFromData() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj(id: "a", from: [:])!
        XCTAssertEqual(o.documentReference.path, "version/1/obj/a")
    }

    func testObjectReferenceFromData() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable { }
            var data: Model?
        }
        let o: Obj = Obj(documentReference: Firestore.firestore().document("version/1/obj/a"), from: [:])!
        XCTAssertEqual(o.documentReference.path, "version/1/obj/a")
    }

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
        o[\.path] = "b"
        XCTAssertEqual(o[\.path], "b")
    }

    func testDocumentCopy() {
                class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable & Equatable {
                var path: String = "a"
            }
            var data: Model?
        }
        let o: Obj = Obj(id: "a")
        XCTAssertEqual(o[\.path], "a")
        o[\.path] = "b"
        let copy: Obj = o.copy()
        XCTAssertEqual(copy[\.path], "b")
    }

    func testObjectListen() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        class Obj: Object, DataRepresentable, DataListenable {
            struct Model: Modelable & Codable & Equatable {
                var path: String = "a"
            }
            var listener: ListenerRegistration?
            var data: Model?
        }

        weak var weakO: Obj?

        do {
            let o: Obj = Obj(id: "a").listen() { (_, _) in
                exp.fulfill()
            }
            weakO = o
            XCTAssertEqual(o[\.path], "a")
            o[\.path] = "b"
            o.update()
            self.wait(for: [exp], timeout: 30)
            XCTAssertEqual(o[\.path], "b")
        }

        XCTAssertNil(weakO)
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

    func testObjectDescription() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable & Equatable {
                init() {
                    s = "abc"
                    d = 123
                    f = -4
                    l = 1_234_567_890_123
                    i = -4444
                    b = false
                    ai = [1, 2, 3, 4]
                    si = ["abc", "def"]
                    caseSensitive = "aaa"
                    casESensitive = "bbb"
                    casESensitivE = "ccc"
                }

                let s: String
                let d: Double
                let f: Float
                let l: CLongLong
                let i: Int
                let b: Bool
                let ai: [Int]
                let si: [String]
                let caseSensitive: String
                let casESensitive: String
                let casESensitivE: String
            }
            var data: Model? = Model()
        }
        let obj: Obj = Obj(Firestore.firestore().document("a/a"))
        obj.createdAt = Timestamp.init(seconds: 0, nanoseconds: 0)
        obj.updatedAt = Timestamp.init(seconds: 0, nanoseconds: 0)
        XCTAssertEqual(obj.description,
"""
obj {
  path: a/a
  createdAt: <FIRTimestamp: seconds=0 nanoseconds=0> (1970-01-01 00:00:00 +0000)
  updatedAt: <FIRTimestamp: seconds=0 nanoseconds=0> (1970-01-01 00:00:00 +0000)
  s: abc
  d: 123.0
  f: -4.0
  l: 1234567890123
  i: -4444
  b: false
  ai: [1, 2, 3, 4]
  si: ["abc", "def"]
  caseSensitive: aaa
  casESensitive: bbb
  casESensitivE: ccc
}
"""
        )
    }
}
