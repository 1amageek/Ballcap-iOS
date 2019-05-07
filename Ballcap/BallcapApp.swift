//
//  BallcapApp.swift
//  Ballcap
//
//  Created by 1amageek on 2019/05/06.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import Firebase

public final class BallcapApp {

    static let `default`: BallcapApp = BallcapApp()

    class func configure(_ rootReference: DocumentReference? = nil) {
        self.default.rootReference = rootReference
    }

    var rootReference: DocumentReference? = nil
}
