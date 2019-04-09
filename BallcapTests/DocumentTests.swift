//
//  DocumentTest.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/03.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
//@testable import Ballcap


class DocumentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testDocumentID() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a")
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
    }

    func testDocumentIDFromDatae() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: [:])!
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
    }

    func testDocumentIDFromModel() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: Model())
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
    }

    func testDocumentIDOtherCollectionReference() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", collectionReference: Firestore.firestore().collection("a"))
        XCTAssertEqual(d.documentReference.path, "a/a")
    }

    func testDocumentIDFromDataOtherCollectionReference() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: [:], collectionReference: Firestore.firestore().collection("a"))!
        XCTAssertEqual(d.documentReference.path, "a/a")
    }

    func testDocumentIDFromModelOtherCollectionReference() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: Model(), collectionReference: Firestore.firestore().collection("a"))
        XCTAssertEqual(d.documentReference.path, "a/a")
    }

    func testDocumentKeyPath() {
        struct Model: Codable, Modelable, Equatable {
            var path: String = "a"
        }
        let document: Document<Model> = Document(id: "a")
        XCTAssertEqual(document[\.path], "a")
    }

    func testDocumentSaveUpdateDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        struct Model: Codable, Modelable, Equatable {
            var a: String?
        }
        let d: Document<Model> = Document(id: "a")
        d[\.a] = "t"
        d.save() { _ in
            Document<Model>.get(id: "a", completion: { (doc, _) in
                XCTAssertEqual(doc!.data!.a, "t")
                doc![\.a] = "s"
                doc?.update() { _ in
                    Document<Model>.get(id: "a", completion: { (doc, _) in
                        XCTAssertEqual(doc!.data!.a, "s")
                        doc?.delete() { _ in
                            Document<Model>.get(id: "a", completion: { (doc, _) in
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

    func testDocumentModelSaveUpdateDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        struct Model: Modelable, Codable, Equatable {

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
                timestamp = Timestamp(date: Date(timeIntervalSince1970: 0))
                serverTimestamp = .resolved(Timestamp(date: Date(timeIntervalSince1970: 0)))
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
            let timestamp: Timestamp
            let serverTimestamp: ServerTimestamp
        }

        let dict = [
            "s": "abc",
            "d": 123,
            "f": -4,
            "l": 1_234_567_890_123,
            "i": -4444,
            "b": false,
            "ai": [1, 2, 3, 4],
            "si": ["abc", "def"],
            "caseSensitive": "aaa",
            "casESensitive": "bbb",
            "casESensitivE": "ccc",
            "timestamp": Timestamp(date: Date(timeIntervalSince1970: 0)),
            "serverTimestamp": Timestamp(date: Date(timeIntervalSince1970: 0))
            ] as [String: Any]

        let d: Document<Model> = Document(id: "a")
        d.save() { _ in
            Document<Model>.get(id: "a", completion: { (doc, _) in
                assertRoundTrip(model: doc?.data!, encoded: dict as [String : Any])
                doc?.delete(completion: { _ in
                    exp.fulfill()
                })
            })
        }
        self.wait(for: [exp], timeout: 30)
    }
}
