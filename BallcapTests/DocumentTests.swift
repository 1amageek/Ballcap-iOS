//
//  DocumentTest.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/03.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage
//@testable import Ballcap


class DocumentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
        BallcapApp.configure(Firestore.firestore().document("version/1"))
    }

    func testDocumentModelName() {
        do {
            struct Model: Codable, Modelable, Equatable {}
            XCTAssertEqual(Document<Model>.name, "model")
        }
        do {
            struct aModel: Codable, Modelable, Equatable {}
            XCTAssertEqual(Document<aModel>.name, "amodel")
        }
        do {
            struct Na: Codable, Modelable, Equatable {}
            XCTAssertEqual(Document<Na>.name, "na")
        }
    }

    func testDocumentCollectionReference() {
        do {
            struct Model: Codable, Modelable, Equatable {}
            XCTAssertEqual(Document<Model>.collectionReference.path, "version/1/model")
        }
        do {
            struct aModel: Codable, Modelable, Equatable {}
            XCTAssertEqual(Document<aModel>.collectionReference.path, "version/1/amodel")
        }
        do {
            struct Na: Codable, Modelable, Equatable {}
            XCTAssertEqual(Document<Na>.collectionReference.path, "version/1/na")
        }
    }

    func testDocumentAutoID() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document()
        XCTAssertEqual(d.documentReference.parent.path, "version/1/model")
        XCTAssertEqual(d.documentReference.path, "version/1/model/\(d.id)")
        XCTAssertEqual(d.storageReference.fullPath, "version/1/model/\(d.id)")
    }

    func testDocumentID() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a")
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
        XCTAssertEqual(d.storageReference.fullPath, "version/1/model/a")
    }

    func testDocumentTypeInference() {
        struct Model: Codable, Modelable, Equatable {}
        let d = Document<Model>(id: "a")
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
        XCTAssertEqual(d.storageReference.fullPath, "version/1/model/a")
    }

    func testDocumentIDFromData() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(documentReference: Firestore.firestore().document("version/1/model/a"), from: [:])!
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
        XCTAssertEqual(d.storageReference.fullPath, "version/1/model/a")
    }

    func testDocumentReferenceFromData() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: [:])!
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
        XCTAssertEqual(d.storageReference.fullPath, "version/1/model/a")
    }

    func testDocumentIDFromModel() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: Model())
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
        XCTAssertEqual(d.storageReference.fullPath, "version/1/model/a")
    }

    func testDocumentIDOtherCollectionReference() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", collectionReference: Firestore.firestore().collection("a"))
        XCTAssertEqual(d.documentReference.path, "a/a")
        XCTAssertEqual(d.storageReference.fullPath, "a/a")
    }

    func testDocumentIDFromDataOtherCollectionReference() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: [:], collectionReference: Firestore.firestore().collection("a"))!
        XCTAssertEqual(d.documentReference.path, "a/a")
        XCTAssertEqual(d.storageReference.fullPath, "a/a")
    }

    func testDocumentIDFromModelOtherCollectionReference() {
        struct Model: Codable, Modelable, Equatable {}
        let d: Document<Model> = Document(id: "a", from: Model(), collectionReference: Firestore.firestore().collection("a"))
        XCTAssertEqual(d.documentReference.path, "a/a")
        XCTAssertEqual(d.storageReference.fullPath, "a/a")
    }

    func testDocumentKeyPath() {
        struct Model: Codable, Modelable, Equatable {
            var path: String = "a"
        }
        let document: Document<Model> = Document(id: "a")
        XCTAssertEqual(document[\.path], "a")
        document[\.path] = "b"
        XCTAssertEqual(document[\.path], "b")
    }

    func testDocumentCopy() {
        struct Model: Codable, Modelable, Equatable {
            var path: String = "a"
        }
        let document: Document<Model> = Document(id: "a")
        XCTAssertEqual(document[\.path], "a")
        document[\.path] = "b"
        let copy: Document<Model> = document.copy()
        XCTAssertEqual(copy[\.path], "b")
    }

    func testDocumentSaveUpdateDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        struct Model: Codable, Modelable {
            var a: String?
        }
        let d: Document<Model> = Document()
        d[\.a] = "t"
        let id: String = d.id
        d.save() { _ in
            Document<Model>.get(id: id, completion: { (doc, _) in
                XCTAssertEqual(doc!.data!.a, "t")
                doc![\.a] = "s"
                doc?.update() { _ in
                    Document<Model>.get(id: id, completion: { (doc, _) in
                        XCTAssertEqual(doc!.data!.a, "s")
                        doc?.delete() { _ in
                            Document<Model>.get(id: id, completion: { (doc, _) in
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

    func testDocumentSaveUpdateDeleteWithBatch() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        struct Model: Codable, Modelable {
            var a: String?
        }
        let d: Document<Model> = Document()
        d[\.a] = "t"
        let id: String = d.id
        let batch: Batch = Batch()
        batch.save(d)
        batch.commit() { _ in
            Document<Model>.get(id: id, completion: { (doc, _) in
                XCTAssertEqual(doc!.data!.a, "t")
                doc![\.a] = "s"
                doc?.update() { _ in
                    Document<Model>.get(id: id, completion: { (doc, _) in
                        XCTAssertEqual(doc!.data!.a, "s")
                        doc?.delete() { _ in
                            Document<Model>.get(id: id, completion: { (doc, _) in
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

    func testDocumentIDSaveUpdateDelete() {
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

    func testDocumentCache() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        struct Model: Codable, Modelable, Equatable {
            var a: String?
        }
        let d: Document<Model> = Document(id: "a")
        let date: Date = Date()
        NSLog("0 - Start")
        d.save() { _ in
            let interval: TimeInterval = Date().timeIntervalSince(date)
            NSLog("1 - Save \(interval)")
            d.documentReference.getDocument(completion: { (_, _) in
                let interval0: TimeInterval = Date().timeIntervalSince(date)
                NSLog("2 - Get \(interval0 - interval)")
                d.documentReference.getDocument(source: FirestoreSource.cache, completion: { (_, _) in
                    let interval1: TimeInterval = Date().timeIntervalSince(date)
                    NSLog("3 - Get from cache \(interval1 - interval0)")
                    d.documentReference.getDocument(completion: { (_, _) in
                        let interval2: TimeInterval = Date().timeIntervalSince(date)
                        NSLog("4 - Get \(interval2 - interval1)")
                        Firestore.firestore().document(d.documentReference.path).getDocument(source: FirestoreSource.server, completion: { (_, _) in
                            let interval3: TimeInterval = Date().timeIntervalSince(date)
                            NSLog("5 - Get from server \(interval3 - interval2)")
                            exp.fulfill()
                        })
                    })
                })
            })
        }
        self.wait(for: [exp], timeout: 30)
    }
}
