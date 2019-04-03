//
//  DocumentSubCollectionTest.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/03.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//


import XCTest
import FirebaseFirestore
//@testable import Ballcap


class DocumentSubCollectionTest: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    //
    func testModelSubCollectionReference() {
        struct Model: Codable, Modelable {
            enum CollectionPaths: String {
                case t
                case s
            }
        }
        struct SubCollectionModel: Codable, Modelable {

        }
        XCTAssertEqual(Model.collectionReference.path, "version/1/model")
        let document: Document<Model> = Document(id: "foo")
        XCTAssertEqual(document.documentReference.path, "version/1/model/foo")
        XCTAssertEqual(document.collection(path: .s, type: SubCollectionModel.self).reference.path, "version/1/model/foo/s")
        XCTAssertEqual(document.collection(path: .t, type: SubCollectionModel.self).reference.path, "version/1/model/foo/t")
    }

    func testModelSubCollectionTypeReference() {
        struct Model: Codable, Modelable {
            enum CollectionPaths: String {
                case t
                case s
            }
        }
        struct SubCollectionModel: Codable, Modelable {

        }
        XCTAssertEqual(Model.collectionReference.path, "version/1/model")
        let document: Document<Model> = Document(id: "foo")
        XCTAssertEqual(document.documentReference.path, "version/1/model/foo")
        let s: DataSource<SubCollectionModel>.Query = document.collection(path: .s)
        let t: DataSource<SubCollectionModel>.Query = document.collection(path: .t)
        XCTAssertEqual(s.reference.path, "version/1/model/foo/s")
        XCTAssertEqual(t.reference.path, "version/1/model/foo/t")
    }

    func testModelSubCollectionDataSource() {
        struct Model: Codable, Modelable {
            enum CollectionPaths: String {
                case t
                case s
            }
        }
        struct SubCollectionModel: Codable, Modelable {

        }
        XCTAssertEqual(Model.collectionReference.path, "version/1/model")
        let document: Document<Model> = Document(id: "foo")
        XCTAssertEqual(document.documentReference.path, "version/1/model/foo")
        let s: DataSource<SubCollectionModel> = document.collection(path: .s).dataSource()
        let t: DataSource<SubCollectionModel> = document.collection(path: .t).dataSource()
        XCTAssertEqual(s.query.reference.path, "version/1/model/foo/s")
        XCTAssertEqual(t.query.reference.path, "version/1/model/foo/t")
    }
}
