//
//  FileUploadManagerTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/09.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage

class FileUploadManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testUpload() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        let data: Data = "test".data(using: .utf8)!
        let files: [File] = [
            File(Storage.storage().reference(withPath: "a"), data: data, mimeType: File.MIMEType.plain),
            File(Storage.storage().reference(withPath: "b"), data: data, mimeType: File.MIMEType.plain)
            ]
        let uploadManager: FileUploadManager = FileUploadManager()
        uploadManager.files = files
        uploadManager.upload { _ in
            files.first?.getData(completion: { (data, _) in
                let text: String = String(data: data!, encoding: .utf8)!
                XCTAssertEqual(text, "test")
                files.last?.getData(completion: { (data, _) in
                    let text: String = String(data: data!, encoding: .utf8)!
                    XCTAssertEqual(text, "test")
                    files.first?.delete({ (_) in
                        files.last?.delete({ (_) in
                            exp.fulfill()
                        })
                    })
                })
            })
        }
        self.wait(for: [exp], timeout: 30)
    }

}

