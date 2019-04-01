//
//  CodableFileTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/01.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

class CodableFileTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testDecodeFile() {
        let ref: StorageReference = Storage.storage().reference().child("/a")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(ref, data: data, name: "n", mimeType: .plain)
        let dict = ["path": "a", "mimeType": "text/plain", "name": "n.txt", "url": nil, "additionalData": nil]
        assertRoundTrip(model: file, encoded: dict as [String : Any])
    }

}
