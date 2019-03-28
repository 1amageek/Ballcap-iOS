// This file is derived from swift/stdlib/public/SDK/Foundation/JSONEncoder.swift
// and swift/stdlib/public/SDK/Foundation/PlistEncoder.swift

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation
import FirebaseFirestore

public extension Firestore {
    struct Decoder {
        public init() {}
        public func decode<T: Decodable>(_ type: T.Type, from container: [String: Any]) throws -> T {
            let decoder = _FirestoreDecoder(referencing: container)
            guard let value = try decoder.unbox(container, as: T.self) else {
                throw DecodingError.valueNotFound(T.self, DecodingError.Context(codingPath: [], debugDescription: "The given dictionary was invalid"))
            }
            return value
        }
    }
}


private class _FirestoreDecoder: Decoder {
    /// Options set on the top-level encoder to pass down the decoding hierarchy.

    // MARK: Properties

    /// The decoder's storage.
    fileprivate var storage: _FirestoreDecodingStorage

    /// The path to the current point in encoding.
    public fileprivate(set) var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] = [:]

    // MARK: - Initialization

    /// Initializes `self` with the given top-level container and options.
    init(referencing container: Any, at codingPath: [CodingKey] = []) {
        storage = _FirestoreDecodingStorage()
        storage.push(container: container)
        self.codingPath = codingPath
    }

    // MARK: - Decoder Methods

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let topContainer = self.storage.topContainer as? [String: Any] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Not a dictionary")
            throw DecodingError.typeMismatch([String: Any].self, context)
        }

        let container = _FirestoreKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }

        guard let topContainer = self.storage.topContainer as? [Any] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Not an array")
            throw DecodingError.typeMismatch([Any].self, context)
        }

        return _FirestoreUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

fileprivate struct _FirestoreDecodingStorage {
    // MARK: Properties

    /// The container stack.
    /// Elements may be any one of the plist types (NSNumber, Date, String, Array, [String : Any]).
    fileprivate private(set) var containers: [Any] = []

    // MARK: - Initialization

    /// Initializes `self` with no containers.
    fileprivate init() {}

    // MARK: - Modifying the Stack

    fileprivate var count: Int {
        return containers.count
    }

    fileprivate var topContainer: Any {
        precondition(containers.count > 0, "Empty container stack.")
        return containers.last!
    }

    fileprivate mutating func push(container: Any) {
        containers.append(container)
    }

    fileprivate mutating func popContainer() {
        precondition(containers.count > 0, "Empty container stack.")
        containers.removeLast()
    }
}

fileprivate struct _FirestoreKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: _FirestoreDecoder

    /// A reference to the container we're reading from.
    private let container: [String: Any]

    /// The path of coding keys taken to get to this point in decoding.
    public private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _FirestoreDecoder, wrapping container: [String: Any]) {
        self.decoder = decoder
        self.container = container
        codingPath = decoder.codingPath
    }

    // MARK: - KeyedDecodingContainerProtocol Methods

    public var allKeys: [Key] {
        return container.keys.compactMap { Key(stringValue: $0) }
    }

    public func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        let entry = try require(key: key)
        return entry is NSNull
    }

    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Bool.self)
        return try require(value: value)
    }

    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Int.self)
        return try require(value: value)
    }

    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Int8.self)
        return try require(value: value)
    }

    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Int16.self)
        return try require(value: value)
    }

    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Int32.self)
        return try require(value: value)
    }

    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Int64.self)
        return try require(value: value)
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: UInt.self)
        return try require(value: value)
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: UInt8.self)
        return try require(value: value)
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: UInt16.self)
        return try require(value: value)
    }

    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: UInt32.self)
        return try require(value: value)
    }

    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: UInt64.self)
        return try require(value: value)
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Float.self)
        return try require(value: value)
    }

    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: Double.self)
        return try require(value: value)
    }

    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: String.self)
        return try require(value: value)
    }

    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        let entry = try require(key: key)

        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value = try decoder.unbox(entry, as: T.self)
        return try require(value: value)
    }

    private func require(key: Key) throws -> Any {
        if let entry = self.container[key.stringValue] {
            return entry
        }

        let description = "No value associated with key \(key) (\"\(key.stringValue)\")."
        let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: description)
        throw DecodingError.keyNotFound(key, context)
    }

    private func require<T>(value: T?) throws -> T {
        if let value = value {
            return value
        }

        let message = "Expected \(T.self) value but found null instead."
        let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: message)
        throw DecodingError.valueNotFound(T.self, context)
    }

    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested keyed container -- no value found for key \"\(key.stringValue)\""))
        }

        guard let dictionary = value as? [String: Any] else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value)
        }

        let container = _FirestoreKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get nested unkeyed container -- no value found for key \"\(key.stringValue)\""))
        }

        guard let array = value as? [Any] else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Not an array")
            throw DecodingError.typeMismatch([Any].self, context)
        }

        return _FirestoreUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { self.decoder.codingPath.removeLast() }

        let value: Any = container[key.stringValue] ?? NSNull()
        return _FirestoreDecoder(referencing: value, at: decoder.codingPath)
    }

    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _FirestoreKey.super)
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

fileprivate struct _FirestoreUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: _FirestoreDecoder

    /// A reference to the container we're reading from.
    private let container: [Any]

    /// The path of coding keys taken to get to this point in decoding.
    public private(set) var codingPath: [CodingKey]

    /// The index of the element we're about to decode.
    public private(set) var currentIndex: Int

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    fileprivate init(referencing decoder: _FirestoreDecoder, wrapping container: [Any]) {
        self.decoder = decoder
        self.container = container
        codingPath = decoder.codingPath
        currentIndex = 0
    }

    // MARK: - UnkeyedDecodingContainer Methods

    public var count: Int? {
        return container.count
    }

    public var isAtEnd: Bool {
        return currentIndex >= count!
    }

    public mutating func decodeNil() throws -> Bool {
        try expectNotAtEnd()

        if container[currentIndex] is NSNull {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }

    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Bool.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: Int.Type) throws -> Int {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Int.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Int8.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Int16.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Int32.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Int64.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: UInt.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: UInt8.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: UInt16.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: UInt32.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: UInt64.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: Float.Type) throws -> Float {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Float.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: Double.Type) throws -> Double {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: Double.self)
        return try require(value: decoded)
    }

    public mutating func decode(_ type: String.Type) throws -> String {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: String.self)
        return try require(value: decoded)
    }

    public mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try expectNotAtEnd()

        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        let decoded = try decoder.unbox(container[currentIndex], as: T.self)
        return try require(value: decoded)
    }

    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        try expectNotAtEnd()

        let value = self.container[self.currentIndex]
        try requireNotNSNull(value)

        guard let dictionary = value as? [String: Any] else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value)
        }

        currentIndex += 1
        let container = _FirestoreKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: dictionary)
        return KeyedDecodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        try expectNotAtEnd()

        let value = container[self.currentIndex]
        try requireNotNSNull(value)

        guard let array = value as? [Any] else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [Any].self, reality: value)
        }

        currentIndex += 1
        return _FirestoreUnkeyedDecodingContainer(referencing: decoder, wrapping: array)
    }

    public mutating func superDecoder() throws -> Decoder {
        decoder.codingPath.append(_FirestoreKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        try expectNotAtEnd()

        let value = container[self.currentIndex]
        currentIndex += 1
        return _FirestoreDecoder(referencing: value, at: decoder.codingPath)
    }

    private func expectNotAtEnd() throws {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: decoder.codingPath + [_FirestoreKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
        }
    }

    private func requireNotNSNull(_ value: Any) throws {
        if !(value is NSNull) {
            return
        }

        let description = "Cannot get keyed decoding container -- found null value instead."
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: description)
        throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, context)
    }

    private mutating func require<T>(value: T?) throws -> T {
        guard let value = value else {
            let message = "Expected \(T.self) value but found null instead."
            let context = DecodingError.Context(codingPath: decoder.codingPath + [_FirestoreKey(index: currentIndex)], debugDescription: message)
            throw DecodingError.valueNotFound(T.self, context)
        }

        currentIndex += 1
        return value
    }
}

extension _FirestoreDecoder: SingleValueDecodingContainer {
    // MARK: SingleValueDecodingContainer Methods

    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }

    public func decodeNil() -> Bool {
        return storage.topContainer is NSNull
    }

    public func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(Bool.self)
        return try unbox(storage.topContainer, as: Bool.self)!
    }

    public func decode(_ type: Int.Type) throws -> Int {
        try expectNonNull(Int.self)
        return try unbox(storage.topContainer, as: Int.self)!
    }

    public func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNull(Int8.self)
        return try unbox(storage.topContainer, as: Int8.self)!
    }

    public func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNull(Int16.self)
        return try unbox(storage.topContainer, as: Int16.self)!
    }

    public func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNull(Int32.self)
        return try unbox(storage.topContainer, as: Int32.self)!
    }

    public func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNull(Int64.self)
        return try unbox(storage.topContainer, as: Int64.self)!
    }

    public func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNull(UInt.self)
        return try unbox(storage.topContainer, as: UInt.self)!
    }

    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(UInt8.self)
        return try unbox(storage.topContainer, as: UInt8.self)!
    }

    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(UInt16.self)
        return try unbox(storage.topContainer, as: UInt16.self)!
    }

    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(UInt32.self)
        return try unbox(storage.topContainer, as: UInt32.self)!
    }

    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(UInt64.self)
        return try unbox(storage.topContainer, as: UInt64.self)!
    }

    public func decode(_ type: Float.Type) throws -> Float {
        try expectNonNull(Float.self)
        return try unbox(storage.topContainer, as: Float.self)!
    }

    public func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(Double.self)
        return try unbox(storage.topContainer, as: Double.self)!
    }

    public func decode(_ type: String.Type) throws -> String {
        try expectNonNull(String.self)
        return try unbox(storage.topContainer, as: String.self)!
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(T.self)
        return try unbox(storage.topContainer, as: T.self)!
    }
}

extension _FirestoreDecoder {
    /// Returns the given value unboxed from a container.
    func unbox(_ value: Any, as type: Bool.Type) throws -> Bool? {
        guard !(value is NSNull) else { return nil }

        if let number = value as? NSNumber {
            // TODO: Add a flag to coerce non-boolean numbers into Bools?
            if number === kCFBooleanTrue as NSNumber {
                return true
            } else if number === kCFBooleanFalse as NSNumber {
                return false
            }
        }

        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: Any, as type: Int.Type) throws -> Int? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int = number.intValue
        guard NSNumber(value: int) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return int
    }

    func unbox(_ value: Any, as type: Int8.Type) throws -> Int8? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int8 = number.int8Value
        guard NSNumber(value: int8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return int8
    }

    func unbox(_ value: Any, as type: Int16.Type) throws -> Int16? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int16 = number.int16Value
        guard NSNumber(value: int16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return int16
    }

    func unbox(_ value: Any, as type: Int32.Type) throws -> Int32? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int32 = number.int32Value
        guard NSNumber(value: int32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return int32
    }

    func unbox(_ value: Any, as type: Int64.Type) throws -> Int64? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int64 = number.int64Value
        guard NSNumber(value: int64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return int64
    }

    func unbox(_ value: Any, as type: UInt.Type) throws -> UInt? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint = number.uintValue
        guard NSNumber(value: uint) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return uint
    }

    func unbox(_ value: Any, as type: UInt8.Type) throws -> UInt8? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint8 = number.uint8Value
        guard NSNumber(value: uint8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return uint8
    }

    func unbox(_ value: Any, as type: UInt16.Type) throws -> UInt16? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint16 = number.uint16Value
        guard NSNumber(value: uint16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return uint16
    }

    func unbox(_ value: Any, as type: UInt32.Type) throws -> UInt32? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint32 = number.uint32Value
        guard NSNumber(value: uint32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return uint32
    }

    func unbox(_ value: Any, as type: UInt64.Type) throws -> UInt64? {
        guard !(value is NSNull) else { return nil }

        guard let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint64 = number.uint64Value
        guard NSNumber(value: uint64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number <\(number)> does not fit in \(type)."))
        }

        return uint64
    }

    func unbox(_ value: Any, as type: Float.Type) throws -> Float? {
        guard !(value is NSNull) else { return nil }

        if let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse {
            // We are willing to return a Float by losing precision:
            // * If the original value was integral,
            //   * and the integral value was > Float.greatestFiniteMagnitude, we will fail
            //   * and the integral value was <= Float.greatestFiniteMagnitude, we are willing to lose precision past 2^24
            // * If it was a Float, you will get back the precise value
            // * If it was a Double or Decimal, you will get back the nearest approximation if it will fit
            let double = number.doubleValue
            guard abs(double) <= Double(Float.greatestFiniteMagnitude) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Decoded number \(number) does not fit in \(type)."))
            }

            return Float(double)
        }

        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: Any, as type: Double.Type) throws -> Double? {
        guard !(value is NSNull) else { return nil }

        if let number = value as? NSNumber, number !== kCFBooleanTrue, number !== kCFBooleanFalse {
            // We are always willing to return the number as a Double:
            // * If the original value was integral, it is guaranteed to fit in a Double; we are willing to lose precision past 2^53 if you encoded a UInt64 but requested a Double
            // * If it was a Float or Double, you will get back the precise value
            // * If it was Decimal, you will get back the nearest approximation
            return number.doubleValue
        }

        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }

    func unbox(_ value: Any, as type: String.Type) throws -> String? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return string
    }

    func unbox(_ value: Any, as type: Date.Type) throws -> Date? {
        guard !(value is NSNull) else { return nil }
        guard let date = value as? Date else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }
        return date
    }

    func unbox(_ value: Any, as type: Data.Type) throws -> Data? {
        guard !(value is NSNull) else { return nil }
        guard let data = value as? Data else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }
        return data
    }

    func unbox(_ value: Any, as type: Decimal.Type) throws -> Decimal? {
        guard !(value is NSNull) else { return nil }

        // Attempt to bridge from NSDecimalNumber.
        if let decimal = value as? Decimal {
            return decimal
        } else {
            let doubleValue = try unbox(value, as: Double.self)!
            return Decimal(doubleValue)
        }
    }

    func unbox<T: Decodable>(_ value: Any, as type: T.Type) throws -> T? {
        if T.self == Date.self || T.self == NSDate.self {
            guard let date = try self.unbox(value, as: Date.self) else { return nil }
            return (date as! T)
        }
        if T.self == Data.self || T.self == NSData.self {
            guard let data = try self.unbox(value, as: Data.self) else { return nil }
            return (data as! T)
        }
        if T.self == URL.self || T.self == NSURL.self {
            guard let urlString = try self.unbox(value, as: String.self) else {
                return nil
            }
            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }
            return (url as! T)
        }
        if T.self == Decimal.self || T.self == NSDecimalNumber.self {
            guard let decimal = try self.unbox(value, as: Decimal.self) else { return nil }
            return (decimal as! T)
        }
        if let v = value as? T {
            if isFirestorePassthroughType(v) {
                // All the native Firestore types that should not be encoded
                return (value as! T)
            }
        }
        storage.push(container: value)
        let decoded = try T(from: self)
        storage.popContainer()
        return decoded
    }
}
