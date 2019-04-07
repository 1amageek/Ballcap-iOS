//
//  DocumentCacheTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

class DocumentCacheTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }


    // TODO: DocumentCache tests

    func testDocumentCacheSetGet() {
        struct Model: Modelable, Codable, Equatable {

            init() {
                s = "abc"
                d = 123
                f = -4
                l = 1_234_567_890_123
                i = -4444
                b = false
                sh = 123
                byte = 45
                uchar = 44
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
            let sh: CShort
            let byte: CChar
            let uchar: CUnsignedChar
            let ai: [Int]
            let si: [String]
            let caseSensitive: String
            let casESensitive: String
            let casESensitivE: String
        }
        let model = Model()
        let dict = [
            "s": "abc",
            "d": 123,
            "f": -4,
            "l": 1_234_567_890_123,
            "i": -4444,
            "b": false,
            "sh": 123,
            "byte": 45,
            "uchar": 44,
            "ai": [1, 2, 3, 4],
            "si": ["abc", "def"],
            "caseSensitive": "aaa",
            "casESensitive": "bbb",
            "casESensitivE": "ccc",
            ] as [String: Any]
        DocumentCache.shared.set(key: "a/a", data: dict)
        XCTAssertEqual(try! DocumentCache.shared.get(modelType: Model.self, path: "a/a"), model)
    }
}
