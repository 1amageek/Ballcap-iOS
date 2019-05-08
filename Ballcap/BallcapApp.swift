//
//  BallcapApp.swift
//  Ballcap
//
//  Created by 1amageek on 2019/05/06.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public final class BallcapApp {

    public static let `default`: BallcapApp = BallcapApp()

    public class func configure(_ rootReference: DocumentReference? = nil) {
        self.default.rootReference = rootReference
    }

    public var rootReference: DocumentReference? = nil
}
