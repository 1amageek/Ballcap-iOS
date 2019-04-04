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
    
    // TODO:
    func testMIMEType() {
        let ref: StorageReference = Storage.storage().reference().child("/a")
        
        // plain
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .plain)
            XCTAssertEqual(file.mimeType, File.MIMEType.plain)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n.txt")
            XCTAssertEqual(file.mimeType, File.MIMEType.plain)
        }
        
        // csv
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .csv)
            XCTAssertEqual(file.mimeType, File.MIMEType.csv)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .csv)
            XCTAssertEqual(file.mimeType, File.MIMEType.csv)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n.csv")
            XCTAssertEqual(file.mimeType, File.MIMEType.csv)
        }
        
        // html
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .html)
            XCTAssertEqual(file.mimeType, File.MIMEType.html)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .html)
            XCTAssertEqual(file.mimeType, File.MIMEType.html)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n.html")
            XCTAssertEqual(file.mimeType, File.MIMEType.html)
        }
        
        // css
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .css)
            XCTAssertEqual(file.mimeType, File.MIMEType.css)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .css)
            XCTAssertEqual(file.mimeType, File.MIMEType.css)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n.css")
            XCTAssertEqual(file.mimeType, File.MIMEType.css)
        }
        
        // javascript
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .javascript)
            XCTAssertEqual(file.mimeType, File.MIMEType.javascript)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n", mimeType: .javascript)
            XCTAssertEqual(file.mimeType, File.MIMEType.javascript)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let file: File = File(ref, data: data, name: "n.js")
            XCTAssertEqual(file.mimeType, File.MIMEType.javascript)
        }
        
        // TODO: more ext
    }
    
    func testCodableFile() {
        let ref: StorageReference = Storage.storage().reference().child("/a")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(ref, data: data, name: "n", mimeType: .plain)
        let dict = ["path": "a", "mimeType": "text/plain", "name": "n.txt", "url": nil, "additionalData": nil]
        assertRoundTrip(model: file, encoded: dict as [String : Any])
    }
    
    func testCodableFileWithAdditinalData() {
        let ref: StorageReference = Storage.storage().reference().child("/a")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(ref, data: data, name: "n", mimeType: .plain)
        file.additionalData = ["foo": "foo"]
        let dict = ["path": "a", "mimeType": "text/plain", "name": "n.txt", "url": nil, "additionalData": ["foo": "foo"]] as [String : Any?]
        assertRoundTrip(model: file, encoded: dict as [String : Any])
    }
    
    func testFileSaveGetDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        let ref: StorageReference = Storage.storage().reference().child("/a")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(ref, data: data, name: "n", mimeType: .plain)
        let task = file.save { (metadata, error) in
            XCTAssertEqual(metadata?.contentType!, File.MIMEType.plain.rawValue)
            XCTAssertEqual(metadata?.path!, "a")
            XCTAssertEqual(file.isUploaded, true)
            XCTAssertNil(StorageTaskStore.shared.get(upload: ref.fullPath))
            let task = file.getData(completion: { (data, error) in
                let text: String = String(data: data!, encoding: .utf8)!
                XCTAssertEqual(text, "test")
                XCTAssertNil(StorageTaskStore.shared.get(download: ref.fullPath))
                file.delete({ (error) in
                    XCTAssertEqual(file.isUploaded, false)
                    file.getData(completion: { (data, error) in
                        XCTAssertNil(data)
                        exp.fulfill()
                    })
                })
            })
            XCTAssertEqual(task, StorageTaskStore.shared.get(download: ref.fullPath))
        }
        XCTAssertEqual(task, StorageTaskStore.shared.get(upload: ref.fullPath))
        self.wait(for: [exp], timeout: 30)
    }
    
    func testIncrementableInt() {
        // TODO: increment test
    }
}
