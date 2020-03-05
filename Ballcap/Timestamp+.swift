//
//  Timestamp+.swift
//  Ballcap
//
//  Created by nori on 2020/03/05.
//  Copyright © 2020 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public func == (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.seconds == rhs.seconds && lhs.nanoseconds == rhs.nanoseconds
}

public func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.seconds == rhs.seconds ? lhs.nanoseconds < rhs.nanoseconds : lhs.seconds < rhs.seconds
}

public func <= (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.seconds == rhs.seconds ? lhs.nanoseconds <= rhs.nanoseconds : lhs.seconds <= rhs.seconds
}

public func > (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.seconds == rhs.seconds ? lhs.nanoseconds > rhs.nanoseconds : lhs.seconds > rhs.seconds
}

public func >= (lhs: Timestamp, rhs: Timestamp) -> Bool {
    return lhs.seconds == rhs.seconds ? lhs.nanoseconds >= rhs.nanoseconds : lhs.seconds >= rhs.seconds
}
