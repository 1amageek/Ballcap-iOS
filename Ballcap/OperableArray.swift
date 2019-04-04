//
//  OperableArray.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public enum OperableArray<Element: Codable>: Codable, ExpressibleByArrayLiteral, RawRepresentable {

    case value([Element])
    case arrayRemove([Element])
    case arrayUnion([Element])

    public typealias RawValue = [Element]

    public typealias ArrayLiteralElement = Element

    public init?(rawValue: [Element]) {
        self = .value(rawValue)
    }

    public var rawValue: [Element] {
        switch self {
        case .value(let value): return value
        default: fatalError()
        }
    }

    public init(arrayLiteral elements: Element...) {
        self = .value(elements)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode([Element].self)
        self = .value(value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .value(let value): try container.encode(value)
        case .arrayRemove(let value): try container.encode(FieldValue.arrayRemove(value))
        case .arrayUnion(let value): try container.encode(FieldValue.arrayUnion(value))
        }
    }
}

extension OperableArray: Equatable where Element: Equatable {
    public static func == (lhs: OperableArray<Element>, rhs: OperableArray<Element>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
