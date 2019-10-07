//
//  IncrementableNumber.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/02.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

public enum IncrementableInt: Codable, Hashable, ExpressibleByIntegerLiteral, RawRepresentable {

    case increment(Int64)
    case value(Int64)

    public typealias IntegerLiteralType = Int64

    public typealias RawValue = Int64

    public init?(rawValue: Int64) {
        self = .value(rawValue)
    }

    public var rawValue: Int64 {
        switch self {
        case .value(let value): return value
        default: fatalError()
        }
    }

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
        case .increment(let value): try container.encode(FieldValue.increment(value))
        case .value(let value): try container.encode(value)
        }
    }
}

public enum IncrementableDouble: Codable, Hashable, ExpressibleByFloatLiteral {

    case increment(Double)
    case value(Double)

    public typealias IntegerLiteralType = Double

    public typealias RawValue = Double

    public init?(rawValue: Double) {
        self = .value(rawValue)
    }

    public var rawValue: Double {
        switch self {
        case .value(let value): return value
        default: fatalError()
        }
    }

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
        case .increment(let value): try container.encode(FieldValue.increment(value))
        case .value(let value): try container.encode(value)
        }
    }
}
