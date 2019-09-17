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
        BallcapApp.configure(Firestore.firestore().document("version/1"))
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

    func testInt() {
        struct Model: Codable, Equatable {
            let x: Int
        }
        let model = Model(x: 42)
        let dict = ["x": 42]
        assertRoundTrip(model: model, encoded: dict)
    }

    func testString() {
        struct Model: Codable, Equatable {
            let x: String
        }
        let model = Model(x: "s")
        let dict = ["x": "s"]
        assertRoundTrip(model: model, encoded: dict)
    }

    // ServerTimestamp

    func testServerTimestamp() {
        struct Model: Codable, Equatable {
            let x: ServerTimestamp
        }
        let model = Model(x: .resolved(Timestamp(seconds: 0, nanoseconds: 0)))
        XCTAssertEqual(model.x.rawValue, Timestamp(seconds: 0, nanoseconds: 0))
    }

    func testEncodeTimestamp() {
        struct Model: Codable, Equatable {
            let x: ServerTimestamp
            let s: ServerTimestamp
        }
        let model = Model(x: .pending, s: .resolved(Timestamp(seconds: 0, nanoseconds: 0)))
        let dict = ["x": FieldValue.serverTimestamp(), "s": Timestamp(seconds: 0, nanoseconds: 0)]
        assertEncodes(model, encoded: dict)
    }

    func testDecodeTimestamp() {
        struct Model: Codable, Equatable {
            let s: ServerTimestamp
        }
        let model = Model(s: .resolved(Timestamp(seconds: 0, nanoseconds: 0)))
        let dict: [String: Any] = ["s": Timestamp(seconds: 0, nanoseconds: 0)]
        assertDecodes(dict, encoded: model)
    }

    // Increment

    func testIncrement() {
        struct Model: Codable, Equatable {
            var x: IncrementableInt = 64
        }
        let model = Model()
        XCTAssertEqual(model.x.rawValue, 64)
    }

    func testEncodeIncrement() {
        struct Model: Codable, Equatable {
            let x: IncrementableInt = .value(Int64(0))
            var s: IncrementableInt = .value(Int64(0))
        }
        var model = Model()
        model.s = .increment(1)
        let enc = try! Firestore.Encoder().encode(model)
        let dict = ["x": 0, "s": FieldValue.increment(Int64(0))] as [String : Any]
        XCTAssertEqual(enc["x"] as! Int, dict["x"] as! Int)
        XCTAssert(enc["s"].self! is FieldValue)
    }

    func testDecodeIncrement() {
        struct Model: Codable, Equatable {
            let x: IncrementableInt = .value(0)
        }
        let model = Model()
        let dict = ["x": 0]
        assertDecodes(dict, encoded: model)
    }

    // Array

    func testOperableArray() {
        struct Model: Codable, Equatable {
            var x: OperableArray<Int> = [0, 0]
        }
        let model = Model()
        XCTAssertEqual(model.x.rawValue, [0, 0])
    }

    func testEncodeOperableArray() {
        struct Model: Codable, Equatable {
            var a: OperableArray<Int> = [0, 0]
            var b: OperableArray<Int> = .arrayRemove([0])
            var c: OperableArray<Int> = .arrayUnion([0])
        }
        let model = Model()
        let enc = try! Firestore.Encoder().encode(model)
        XCTAssertEqual(enc["a"] as! [Int], [0, 0])
        XCTAssert(enc["b"].self! is FieldValue)
        XCTAssert(enc["c"].self! is FieldValue)
    }

    func testDecodeOperableArray() {
        struct Model: Codable, Equatable {
            var a: OperableArray<Int> = [0, 0]
        }
        let model = Model()
        let dict = ["a": [0, 0]]
        assertDecodes(dict, encoded: model)
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

    // Inspired by https://github.com/firebase/firebase-android-sdk/blob/master/firebase-firestore/src/test/java/com/google/firebase/firestore/util/MapperTest.java
    func testBeans() {
        struct Model: Codable, Equatable {
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
        let model = Model(
            s: "abc",
            d: 123,
            f: -4,
            l: 1_234_567_890_123,
            i: -4444,
            b: false,
            sh: 123,
            byte: 45,
            uchar: 44,
            ai: [1, 2, 3, 4],
            si: ["abc", "def"],
            caseSensitive: "aaa",
            casESensitive: "bbb",
            casESensitivE: "ccc"
        )
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

        assertRoundTrip(model: model, encoded: dict)
    }

    func testCodingKeys() {
        struct Model: Codable, Equatable {
            var s: String
            var ms: String
            var d: Double
            var md: Double
            var i: Int
            var mi: Int
            var b: Bool
            var mb: Bool

            // Use CodingKeys to only encode part of the struct.
            enum CodingKeys: String, CodingKey {
                case s
                case d
                case i
                case b
            }

            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                s = try values.decode(String.self, forKey: .s)
                d = try values.decode(Double.self, forKey: .d)
                i = try values.decode(Int.self, forKey: .i)
                b = try values.decode(Bool.self, forKey: .b)
                ms = "filler"
                md = 42.42
                mi = -9
                mb = false
            }

            public init(ins: String, inms: String, ind: Double, inmd: Double, ini: Int, inmi: Int, inb: Bool, inmb: Bool) {
                s = ins
                d = ind
                i = ini
                b = inb
                ms = inms
                md = inmd
                mi = inmi
                mb = inmb
            }
        }
        let model = Model(
            ins: "abc",
            inms: "dummy",
            ind: 123.3,
            inmd: 0,
            ini: -4444,
            inmi: 0,
            inb: true,
            inmb: true
        )
        let dict = [
            "s": "abc",
            "d": 123.3,
            "i": -4444,
            "b": true,
            ] as [String: Any]

        let model2 = try! Firestore.Decoder().decode(Model.self, from: dict)
        XCTAssertEqual(model.s, model2.s)
        XCTAssertEqual(model.d, model2.d)
        XCTAssertEqual(model.i, model2.i)
        XCTAssertEqual(model.b, model2.b)
        XCTAssertEqual(model2.ms, "filler")
        XCTAssertEqual(model2.md, 42.42)
        XCTAssertEqual(model2.mi, -9)
        XCTAssertEqual(model2.mb, false)

        let encodedDict = try! Firestore.Encoder().encode(model)
        XCTAssertEqual(encodedDict["s"] as! String, "abc")
        XCTAssertEqual(encodedDict["d"] as! Double, 123.3)
        XCTAssertEqual(encodedDict["i"] as! Int, -4444)
        XCTAssertEqual(encodedDict["b"] as! Bool, true)
        XCTAssertNil(encodedDict["ms"])
        XCTAssertNil(encodedDict["md"])
        XCTAssertNil(encodedDict["mi"])
        XCTAssertNil(encodedDict["mb"])
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
        XCTAssertEqual(document[\.ref].path, "a/a")
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
