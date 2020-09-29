//
//  DisposeBagTests.swift
//  BallcapTests
//
//  Created by 1amageek on 2019/05/17.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import XCTest
import FirebaseFirestore
import FirebaseStorage
@testable import Ballcap_iOS

class DisposeBagTests: XCTestCase {

    override func setUp() {
        super.setUp()
        _ = FirebaseTest.shared
    }

    func testDisposeBagMemoryLead() {
        class Obj: Object, DataRepresentable {
            struct Model: Modelable & Codable & Equatable {
                var a: String = "a"
            }
            var data: Model?
        }
        weak var disposeBag: DisposeBag? = nil
        weak var disposer: Disposer? = nil
        do {
            let bag: DisposeBag = DisposeBag()
            disposeBag = bag
            let d = Obj.listen(id: "a") { (_, _) in

                }
            disposer = d
            d.disposed(by: bag)
        }
        XCTAssertNil(disposeBag)
        XCTAssertNil(disposer)
    }

}
