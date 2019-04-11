//
//  OperableArray.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public enum OperableArray<Element: Codable>: Codable & ExpressibleByArrayLiteral & RawRepresentable {

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

extension OperableArray: Collection {

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        switch self {
        case .value(let value): return value.count
        case .arrayRemove(let value): return value.count
        case .arrayUnion(let value): return value.count
        }
    }

    public func index(after i: Int) -> Int {
        return i + 1
    }

    public var isEmpty: Bool {
        switch self {
        case .value(let value): return value.isEmpty
        case .arrayRemove(let value): return value.isEmpty
        case .arrayUnion(let value): return value.isEmpty
        }
    }

    public var first: Element? {
        switch self {
        case .value(let value): return value.first
        case .arrayRemove(let value): return value.first
        case .arrayUnion(let value): return value.first
        }
    }

    public var last: Element? {
        switch self {
        case .value(let value): return value.last
        case .arrayRemove(let value): return value.last
        case .arrayUnion(let value): return value.last
        }
    }

    public subscript(index: Int) -> Element {
        switch self {
        case .value(let value): return value[index]
        case .arrayRemove(let value): return value[index]
        case .arrayUnion(let value): return value[index]
        }
    }
}
