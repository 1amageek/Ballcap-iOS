//
//  ModelableTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/05/14.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
//@testable import Ballcap


class ModelableTests: XCTestCase {

    func testDecode() {
        struct Model: Modelable, Codable, Equatable {


            var s: String = ""

            enum Keys: String, CodingKey {
                case s
            }

            init() {
                self.s = ""
            }

            init(s: String) {
                self.s = s
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: Keys.self)
                var s: String = "initialValue"
                do {
                    s = try container.decode(String.self, forKey: .s)
                } catch _ { }
                self.init(s: s)
            }
        }

        let data: Model = try! Firestore.Decoder().decode(Model.self, from: ["s": NSNull()])
        XCTAssertEqual(data.s, "initialValue")
    }

    func testModelName() {
        struct Model: Modelable, Codable, Equatable {
            static var name: String {
                return "name"
            }
        }
        XCTAssertEqual(Document<Model>.name, "name")
    }

    func testDebugDescription() {
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

        let model = Model()
        XCTAssertEqual(model.debugDescription,
                       """
model {
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
""")
    }
}
