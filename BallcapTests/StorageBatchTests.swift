//
//  StorageBatchTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/04/09.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage
@testable import Ballcap_iOS

class StorageBatchTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testBatchSaveDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        let data: Data = "test".data(using: .utf8)!
        let batch: StorageBatch = StorageBatch()
        batch.save(File(Storage.storage().reference(withPath: "b"), data: data, mimeType: File.MIMEType.plain))
        batch.commit { (_) in
            let file = File(Storage.storage().reference(withPath: "b"), mimeType: File.MIMEType.plain)
            file.getData(completion: { (data, error) in
                let text: String = String(data: data!, encoding: .utf8)!
                XCTAssertEqual(text, "test")
                let batch: StorageBatch = StorageBatch()
                batch.delete(file)
                batch.commit({ (_) in
                    file.getData(completion: { (data, _) in
                        XCTAssertNil(data)
                        exp.fulfill()
                    })
                })
            })
        }
        self.wait(for: [exp], timeout: 30)
    }

    func testBatchMultiFilesSaveDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        let data: Data = "test".data(using: .utf8)!
        let batch: StorageBatch = StorageBatch()

        let c: File = File(Storage.storage().reference(withPath: "c"), data: data, mimeType: File.MIMEType.plain)
        let e: File = File(Storage.storage().reference(withPath: "e"), data: data, mimeType: File.MIMEType.plain)

        let files: [File] = [c, e]
        batch.save(files)
        batch.commit { (error) in

            if let error = error {
                print(error)
            }

            let file = File(Storage.storage().reference(withPath: "c"), mimeType: File.MIMEType.plain)
            file.getData(completion: { (data, error) in

                if let error = error {
                    print(error)
                }

                let text: String = String(data: data!, encoding: .utf8)!
                XCTAssertEqual(text, "test")

                let file = File(Storage.storage().reference(withPath: "e"), mimeType: File.MIMEType.plain)
                file.getData(completion: { (data, _) in
                    let text: String = String(data: data!, encoding: .utf8)!
                    XCTAssertEqual(text, "test")
                    let batch: StorageBatch = StorageBatch()
                    batch.delete(
                        [
                            File(Storage.storage().reference(withPath: "c"), mimeType: File.MIMEType.plain),
                            File(Storage.storage().reference(withPath: "e"), mimeType: File.MIMEType.plain)
                        ]
                    )
                    batch.commit({ (_) in
                        let file = File(Storage.storage().reference(withPath: "c"), mimeType: File.MIMEType.plain)
                        file.getData(completion: { (data, _) in
                            XCTAssertNil(data)
                            let file = File(Storage.storage().reference(withPath: "e"), mimeType: File.MIMEType.plain)
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

