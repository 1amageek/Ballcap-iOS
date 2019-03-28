//
//  CodableDocumentTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
@testable import Ballcap

fileprivate func assertRoundTrip<X: Equatable & Codable>(model: X, encoded: [String: Any]) -> Void {
    let enc = assertEncodes(model, encoded: encoded)
    assertDecodes(enc, encoded: model)
}

fileprivate func assertEncodes<X: Equatable & Codable>(_ model: X, encoded: [String: Any]) -> [String: Any] {
    do {
        let enc = try Firestore.Encoder().encode(model)
        XCTAssertEqual(enc as NSDictionary, encoded as NSDictionary)
        return enc
    } catch {
        XCTFail("Failed to encode \(X.self): error: \(error)")
    }
    return ["": -1]
}

fileprivate func assertDecodes<X: Equatable & Codable>(_ model: [String: Any], encoded: X) -> Void {
    do {
        let decoded = try Firestore.Decoder().decode(X.self, from: model)
        XCTAssertEqual(decoded, encoded)
    } catch {
        XCTFail("Failed to decode \(X.self): \(error)")
    }
}

fileprivate func assertDecodingThrows<X: Equatable & Codable>(_ model: [String: Any], encoded: X) -> Void {
    do {
        _ = try Firestore.Decoder().decode(X.self, from: model)
    } catch {
        return
    }
    XCTFail("Failed to throw")
}

class CodableDocumentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testInt() {
        struct Model: Codable, Equatable {
            let x: Int
        }
        let model = Model(x: 42)
        let dict = ["x": 42]
        assertRoundTrip(model: model, encoded: dict)
    }

    func testText() {
        class Model: Object {
            let x: String = "42"
        }
        let model = Model()
        let enc = try! Firestore.Encoder().encode(model)
        print("!!!!!", enc)
    }


    func testDocument() {

        class Model: Codable {
//            var reference: DocumentReference!
            var id: String = "aaaa"
        }
//
//        let model: Model = Model()
//        do {
//            let data = try Firestore.Encoder().encode(model)
//            print("!!@@!@@!!", data)
//        } catch (let error) {
//            print(error)
//        }

//        assertRoundTrip(model: model3, encoded: ["id": NS, "e": ["timestamp": timestamp]])
    }
}
