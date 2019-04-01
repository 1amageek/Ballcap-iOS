//
//  TestHelper.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/01.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

func assertRoundTrip<X: Equatable & Codable>(model: X, encoded: [String: Any]) -> Void {
    let enc = assertEncodes(model, encoded: encoded)
    assertDecodes(enc, encoded: model)
}

func assertEncodes<X: Equatable & Codable>(_ model: X, encoded: [String: Any]) -> [String: Any] {
    do {
        let enc = try Firestore.Encoder().encode(model)
        XCTAssertEqual(enc as NSDictionary, encoded as NSDictionary)
        return enc
    } catch {
        XCTFail("Failed to encode \(X.self): error: \(error)")
    }
    return ["": -1]
}

func assertDecodes<X: Equatable & Codable>(_ model: [String: Any], encoded: X) -> Void {
    do {
        let decoded = try Firestore.Decoder().decode(X.self, from: model)
        XCTAssertEqual(decoded, encoded)
    } catch {
        XCTFail("Failed to decode \(X.self): \(error)")
    }
}

func assertDecodingThrows<X: Equatable & Codable>(_ model: [String: Any], encoded: X) -> Void {
    do {
        _ = try Firestore.Decoder().decode(X.self, from: model)
    } catch {
        return
    }
    XCTFail("Failed to throw")
}
