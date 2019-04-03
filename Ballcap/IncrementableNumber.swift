//
//  IncrementableNumber.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/02.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public enum IncrementableInt: Codable, Hashable, ExpressibleByIntegerLiteral {

    case increment(Int64)
    case value(Int64)

    public typealias IntegerLiteralType = Int64

    public init(integerLiteral value: Int64) {
        self = .value(value)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Int64.self)
        self = .value(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch (self) {
        case .increment(let value):
            try container.encode(FieldValue.increment(value))
            break
        case .value(let value):
            try container.encode(value)
            break
        }
    }
}

public enum IncrementableDouble: Codable, Hashable, ExpressibleByFloatLiteral {

    case increment(Double)
    case value(Double)

    public typealias IntegerLiteralType = Double

    public init(floatLiteral value: Double) {
        self = .value(value)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Double.self)
        self = .value(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch (self) {
        case .increment(let value):
            try container.encode(FieldValue.increment(value))
            break
        case .value(let value):
            try container.encode(value)
            break
        }
    }
}
