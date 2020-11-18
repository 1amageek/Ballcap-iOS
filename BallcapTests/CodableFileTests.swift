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
@testable import Ballcap_iOS

class CodableFileTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }
    
    // TODO:
    func testMIMEType() {

        // plain
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .plain)
            XCTAssertEqual(file.mimeType, File.MIMEType.plain)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n.txt")
            let file: File = File(ref, data: data)
            XCTAssertEqual(file.mimeType, File.MIMEType.plain)
        }
        
        // csv
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .csv)
            XCTAssertEqual(file.mimeType, File.MIMEType.csv)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .csv)
            XCTAssertEqual(file.mimeType, File.MIMEType.csv)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n.csv")
            let file: File = File(ref, data: data)
            XCTAssertEqual(file.mimeType, File.MIMEType.csv)
        }
        
        // html
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .html)
            XCTAssertEqual(file.mimeType, File.MIMEType.html)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .html)
            XCTAssertEqual(file.mimeType, File.MIMEType.html)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n.html")
            let file: File = File(ref, data: data)
            XCTAssertEqual(file.mimeType, File.MIMEType.html)
        }
        
        // css
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .css)
            XCTAssertEqual(file.mimeType, File.MIMEType.css)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .css)
            XCTAssertEqual(file.mimeType, File.MIMEType.css)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n.css")
            let file: File = File(ref, data: data)
            XCTAssertEqual(file.mimeType, File.MIMEType.css)
        }
        
        // javascript
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .javascript)
            XCTAssertEqual(file.mimeType, File.MIMEType.javascript)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n")
            let file: File = File(ref, data: data, mimeType: .javascript)
            XCTAssertEqual(file.mimeType, File.MIMEType.javascript)
        }
        
        do {
            let data: Data = "test".data(using: .utf8)!
            let ref: StorageReference = Storage.storage().reference().child("/a/n.js")
            let file: File = File(ref, data: data)
            XCTAssertEqual(file.mimeType, File.MIMEType.javascript)
        }
        
        // TODO: more ext
    }
    
    func testCodableFile() {
        let ref: StorageReference = Storage.storage().reference().child("/a/n.txt")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(ref, data: data, mimeType: .plain)
        let dict = ["path": "a/n.txt", "mimeType": "text/plain", "url": nil, "metadata": [:]] as [String : Any?]
        assertRoundTrip(model: file, encoded: dict as [String : Any])
    }
    
    func testCodableFileWithAdditinalData() {
        let ref: StorageReference = Storage.storage().reference().child("/a/n")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(ref, data: data, mimeType: .plain)
        file.metadata = ["foo": "foo"]
        let dict = ["path": "a/n.txt", "mimeType": "text/plain", "url": nil, "metadata": ["foo": "foo"]] as [String : Any?]
        assertRoundTrip(model: file, encoded: dict as [String : Any])
    }
    
    func testFileSaveGetDelete() {
        let exp: XCTestExpectation = XCTestExpectation(description: "")
        let ref: StorageReference = Storage.storage().reference().child("/a/n")
        let data: Data = "test".data(using: .utf8)!
        let file: File = File(ref, data: data, mimeType: .plain)
        let task = file.save { (metadata, error) in
            XCTAssertEqual(metadata?.contentType!, File.MIMEType.plain.rawValue)
            XCTAssertEqual(metadata?.path!, "a/n.txt")
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
            XCTAssertEqual(task, StorageTaskStore.shared.get(download: file.path))
        }
        XCTAssertEqual(task, StorageTaskStore.shared.get(upload: file.path))
        self.wait(for: [exp], timeout: 30)
    }
    
    func testIncrementableInt() {
        // TODO: increment test
    }
}
