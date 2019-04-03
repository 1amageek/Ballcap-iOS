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


class DocumentTest: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testDocumentID() {
        struct Model: Codable, Modelable {}
        let d: Document<Model> = Document(id: "a")
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
    }

    func testDocumentIDFromDatae() {
        struct Model: Codable, Modelable {}
        let d: Document<Model> = Document(id: "a", from: [:])!
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
    }

    func testDocumentIDFromModel() {
        struct Model: Codable, Modelable {}
        let d: Document<Model> = Document(id: "a", from: Model())
        XCTAssertEqual(d.documentReference.path, "version/1/model/a")
    }

    func testDocumentIDOtherCollectionReference() {
        struct Model: Codable, Modelable {}
        let d: Document<Model> = Document(id: "a", collectionReference: Firestore.firestore().collection("a"))
        XCTAssertEqual(d.documentReference.path, "a/a")
    }

    func testDocumentIDFromDataOtherCollectionReference() {
        struct Model: Codable, Modelable {}
        let d: Document<Model> = Document(id: "a", from: [:], collectionReference: Firestore.firestore().collection("a"))!
        XCTAssertEqual(d.documentReference.path, "a/a")
    }

    func testDocumentIDFromModelOtherCollectionReference() {
        struct Model: Codable, Modelable {}
        let d: Document<Model> = Document(id: "a", from: Model(), collectionReference: Firestore.firestore().collection("a"))
        XCTAssertEqual(d.documentReference.path, "a/a")
    }

}