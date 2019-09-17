//
//  Document.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore
import FirebaseStorage

public final class Document<Model: Modelable & Codable>: Object, DataRepresentable, DataCacheable {

    public var data: Model?

    public override class var name: String {
        return Model.name
    }

    public class var collectionReference: CollectionReference {
        return Model.collectionReference
    }

    public override var storageReference: StorageReference {
        return Storage.storage().reference(withPath: self.documentReference.path)
    }

//    public convenience init() {
//        self.init(Model.collectionReference.document())
//        self.data = Model()
//    }
//
//    public required init(documentReference: DocumentReference) {
//        super.init(documentReference)
//        self.data = Model()
//    }

//    public convenience required init(id: String, collectionReference: CollectionReference? = nil) {
//        let collectionReference: CollectionReference = collectionReference ?? Model.collectionReference
//        self.init(documentReference: collectionReference.document(id))
//    }
//
//    public convenience init?(id: String, from data: [String: Any], collectionReference: CollectionReference? = nil) {
//        let collectionReference: CollectionReference = collectionReference ?? Model.collectionReference
//        self.init(documentReference: collectionReference.document(id))
//        do {
//            self.data = try Firestore.Decoder().decode(Model.self, from: data)
//            if data.keys.contains("createdAt") {
//                self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
//            }
//            if data.keys.contains("updatedAt") {
//                self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
//            }
//        } catch (let error) {
//            print(error)
//            return nil
//        }
//    }

//    public convenience init?(documentReference: DocumentReference, from data: [String: Any]) {
//        self.init(documentReference: documentReference)
//        do {
//            self.data = try Firestore.Decoder().decode(Model.self, from: data)
//            if data.keys.contains("createdAt") {
//                self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
//            }
//            if data.keys.contains("updatedAt") {
//                self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
//            }
//        } catch (let error) {
//            print(error)
//            return nil
//        }
//    }

//    public convenience init?(snapshot: DocumentSnapshot) {
//        self.init(documentReference: snapshot.reference)
//        self.snapshot = snapshot
//        guard let data: [String: Any] = snapshot.data(with: .estimate) else {
//            self.snapshot = snapshot
//            return
//        }
//        do {
//            self.data = try Firestore.Decoder().decode(Model.self, from: data)
//            if data.keys.contains("createdAt") {
//                self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
//            }
//            if data.keys.contains("updatedAt") {
//                self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
//            }
//            DocumentCache.shared.set(key: snapshot.reference.path, data: data)
//        } catch (let error) {
//            print(error)
//            return nil
//        }
//    }

//    public convenience init(id: String, from data: Model, collectionReference: CollectionReference? = nil) {
//        let collectionReference: CollectionReference = collectionReference ?? Model.collectionReference
//        self.init(documentReference: collectionReference.document(id))
//        self.data = data
//    }

    public required init(_ documentReference: DocumentReference) {
        super.init(documentReference)
    }

    // MARK: -

    public static func get(documentReference: DocumentReference, source: FirestoreSource = FirestoreSource.default, completion: @escaping ((Document?, Error?) -> Void)) {
        documentReference.getDocument(source: source) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }
            guard let document: Document = Document(snapshot: snapshot) else {
                completion(nil, DocumentError.invalidData(snapshot.data()))
                return
            }
            completion(document, nil)
        }
    }

    public static func get(id: String, source: FirestoreSource = FirestoreSource.default, completion: @escaping ((Document?, Error?) -> Void)) {
        let documentReference: DocumentReference = Document.init(id: id).documentReference
        self.get(documentReference: documentReference, source: source, completion: completion)
    }

    public static func listen(id: String, includeMetadataChanges: Bool = true, completion: @escaping ((Document?, Error?) -> Void)) -> Disposer {
        let listenr: ListenerRegistration = Document.collectionReference.document(id).addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }
            guard let document: Document = Document(snapshot: snapshot) else {
                completion(nil, DocumentError.invalidData(snapshot.data()))
                return
            }
            completion(document, nil)
        }
        return Disposer(.value(listenr))
    }
}
