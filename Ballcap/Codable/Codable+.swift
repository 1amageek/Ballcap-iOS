import FirebaseFirestore
import Firebase

private func encodeOrDie<T: Encodable>(_ value: T) -> [String: Any] {
    do {
        return try Firestore.Encoder().encode(value)
    } catch let error {
        fatalError("Unable to encode data with Firestore encoder: \(error)")
    }
}

extension CollectionReference {
    public func addDocument<T: Encodable>(from encodable: T) -> DocumentReference {
        let encoded = encodeOrDie(encodable)
        return addDocument(data: encoded)
    }

    public func addDocument<T: Encodable>(from encodable: T, _ completion: ((Error?) -> Void)?) -> DocumentReference {
        let encoded = encodeOrDie(encodable)
        return addDocument(data: encoded, completion: completion)
    }
}

extension DocumentReference {
    public func setData<T: Encodable>(from encodable: T) {
        let encoded = encodeOrDie(encodable)
        setData(encoded)
    }

    public func setData<T: Encodable>(from encodable: T, _ completion: ((Error?) -> Void)?) {
        let encoded = encodeOrDie(encodable)
        setData(encoded, completion: completion)
    }
}

extension DocumentSnapshot {
    public func data<T: Decodable>(as type: T.Type) throws -> T {
        guard let dict = data() else {
            throw DecodingError.valueNotFound(T.self,
                                              DecodingError.Context(codingPath: [],
                                                                    debugDescription: "Data was empty"))
        }
        return try Firestore.Decoder().decode(T.self, from: dict)
    }
}

extension Transaction {
    public func setData<T: Encodable>(from encodable: T, forDocument: DocumentReference) {
        let encoded = encodeOrDie(encodable)
        setData(encoded, forDocument: forDocument)
    }
}

//extension WriteBatch {
//    public func setData<T: Encodable>(from encodable: T, forDocument: DocumentReference) {
//        let encoded = encodeOrDie(encodable)
//        setData(encoded, forDocument: forDocument)
//    }
//}
