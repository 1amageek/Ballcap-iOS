//
//  FileTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

class FileTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testReferencePath() {
        let data: Data = "test".data(using: .utf8)!
        let f: File = File(Storage.storage().reference(withPath: "a"), data: data, name: "b", mimeType: File.MIMEType.plain)
        XCTAssertEqual(f.storageReference.fullPath, "a/b.txt")
    }

    func testFileUnique() {
        var s: Set<File> = []
        let data: Data = "test".data(using: .utf8)!
        let file0: File = File(Storage.storage().reference(withPath: "a"), data: data, name: "b", mimeType: File.MIMEType.plain)
        s.insert(file0)
        let file1: File = File(Storage.storage().reference(withPath: "a"), data: data, name: "b", mimeType: File.MIMEType.plain)
        s.insert(file1)
        XCTAssertEqual(s.count, 1)
    }

    func testFile() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(Storage.storage().reference(withPath: "a"), data: data, mimeType: File.MIMEType.plain)
        file.save { (_, _) in
            NSLog("0")
            file.getData(completion: { (data, _) in
                NSLog("1")
                let text: String = String(data: data!, encoding: .utf8)!
                XCTAssertEqual(text, "test")
                file.getData(completion: { (data, _) in
                    NSLog("2")
                    let text: String = String(data: data!, encoding: .utf8)!
                    XCTAssertEqual(text, "test")
                    file.getData(completion: { (data, _) in
                        NSLog("3")
                        file.delete({ (_) in
                            file.getData(completion: { (data, _) in
                                XCTAssertNil(data)
                                exp.fulfill()
                            })
                        })
                    })
                })
            })
        }
        self.wait(for: [exp], timeout: 30)
    }

}
