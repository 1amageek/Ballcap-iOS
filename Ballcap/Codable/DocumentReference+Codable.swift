//
//  DocumentReference+Codable.swift
//  Pring
//
//  Created by 1amageek on 2019/03/26.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore


private protocol CodableDocumentReference: Codable { }

extension CodableDocumentReference {
    public init(from decoder: Decoder) throws {
        throw FirestoreDecodingError.decodingIsNotSupported
    }

    public func encode(to encoder: Encoder) throws {
        throw FirestoreEncodingError.encodingIsNotSupported
    }
}

extension DocumentReference: CodableDocumentReference { }
