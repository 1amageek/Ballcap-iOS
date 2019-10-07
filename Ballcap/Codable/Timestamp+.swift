//
//  Timestamp+.swift
//  Ballcap
//
//  Created by 1amageek on 2019/10/07.
//  Copyright © 2019 Stamp Inc. All rights reserved.
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
