//
//  CodableDocumentTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
//@testable import Ballcap


class CodableDocumentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    // 
    func testModelCollectionReference() {
        struct Model: Codable, Modelable {}
        XCTAssertEqual(Model.collectionReference.path, "version/1/model")
    }

    func testModelDocumentReference() {
        struct Model: Codable, Modelable {}
        let document: Document<Model> = Document(id: "foo")
        XCTAssertEqual(document.documentReference.path, "version/1/model/foo")
    }

    func testModelOverrideCollectionReference() {
        struct Model: Codable, Modelable {
            static var path: String {
                return "foo"
            }
        }
        XCTAssertEqual(Model.collectionReference.path, "foo")
    }

    func testModelOverrideDocumentReference() {
        struct Model: Codable, Modelable {
            static var path: String {
                return "foo"
            }
        }
        let document: Document<Model> = Document(id: "foo")
        XCTAssertEqual(document.documentReference.path, "foo/foo")
    }

    func testInt() {
        struct Model: Codable, Equatable {
            let x: Int
        }
        let model = Model(x: 42)
        let dict = ["x": 42]
        assertRoundTrip(model: model, encoded: dict)
    }

    func testDocument() {
        struct Model: Codable, Equatable, Modelable {
            let number: Int = 0
            var string: String = "Ballcap"
        }
        let document: Document<Model> = Document()
        let dict: [String: Any] = ["number": 0, "string": "Ballcap"]
        assertRoundTrip(model: document.data!, encoded: dict)
    }

    func testDocumentSubScriptValueRead() {
        struct Model: Codable, Equatable, Modelable {
            var number: Int = 0
            var string: String = "Ballcap"
        }
        let document: Document<Model> = Document()
        XCTAssertEqual(document[\.number], 0)
    }

    func testDocumentSubScriptValueWrite() {
        struct Model: Codable, Equatable, Modelable {
            var number: Int = 0
            var string: String = "Ballcap"
        }
        let document: Document<Model> = Document()
        document[\.number] = 1
        let dict: [String: Any] = ["number": 1, "string": "Ballcap"]
        assertRoundTrip(model: document.data!, encoded: dict)
    }

    func testDocumentSubScriptRefRead() {
        struct Model: Codable, Equatable, Modelable {
            var ref: DocumentReference = Firestore.firestore().document("a/a")
        }
        let document: Document<Model> = Document()
        XCTAssertEqual(document[\.ref]?.path, "a/a")
    }

    func testDocumentSubScriptRefWrite() {
        struct Model: Codable, Equatable, Modelable {
            var ref: DocumentReference = Firestore.firestore().document("a/a")
        }
        let document: Document<Model> = Document()
        document[\.ref] = Firestore.firestore().document("b/b")
        let dict: [String: Any] = ["ref": Firestore.firestore().document("b/b")]
        assertRoundTrip(model: document.data!, encoded: dict)
    }
}
