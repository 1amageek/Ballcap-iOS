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
}
