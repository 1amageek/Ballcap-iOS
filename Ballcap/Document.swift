//
//  Document.swift
//  Ballcap
//
//  Created by 1amageek on 2019/04/05.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore

public final class Document<Model: Modelable & Codable>: Object, DataRepresentable {

    public var data: Model?

    public class var modelName: String {
        return String(describing: Mirror(reflecting: Model.self).subjectType).components(separatedBy: ".").first!.lowercased()
    }

    required init(documentReference: DocumentReference) {
        super.init(documentReference)
        self.data = Model()
    }

    convenience required init(id: String, collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Model.collectionReference
        self.init(documentReference: collectionReference.document(id))
    }

    convenience init?(id: String, from data: [String: Any], collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Model.collectionReference
        self.init(documentReference: collectionReference.document(id))
        do {
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
            self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
            self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
        } catch (let error) {
            print(error)
            return nil
        }
    }

    convenience init?(snapshot: DocumentSnapshot) {
        self.init(documentReference: snapshot.reference)
        self.snapshot = snapshot
        guard let data: [String: Any] = snapshot.data() else {
            self.snapshot = snapshot
            return
        }
        do {
            self.data = try Firestore.Decoder().decode(Model.self, from: data)
            self.createdAt = data["createdAt"] as? Timestamp ?? Timestamp(date: Date())
            self.updatedAt = data["updatedAt"] as? Timestamp ?? Timestamp(date: Date())
        } catch (let error) {
            print(error)
            return nil
        }
    }

    convenience init(id: String, from data: Model, collectionReference: CollectionReference? = nil) {
        let collectionReference: CollectionReference = collectionReference ?? Model.collectionReference
        self.init(documentReference: collectionReference.document(id))
        self.data = data
    }

    public required init(_ documentReference: DocumentReference) {
        super.init(documentReference)
    }

    // MARK: -

    static func get(documentReference: DocumentReference, cachePolicy: CachePolicy = .default, completion: @escaping ((Document?, Error?) -> Void)) {
        switch cachePolicy {
        case .default:
            if let document: Document = self.get(documentReference: documentReference) {
                completion(document, nil)
            }
            documentReference.getDocument { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        case .cacheOnly:
            if let document: Document = self.get(documentReference: documentReference) {
                completion(document, nil)
            }
            documentReference.getDocument(source: FirestoreSource.cache) { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        case .networkOnly:
            documentReference.getDocument(source: FirestoreSource.server) { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                guard let snapshot = snapshot, snapshot.exists else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                guard let document: Document = Document(snapshot: snapshot) else {
                    completion(nil, DocumentError.invalidData)
                    return
                }
                completion(document, nil)
            }
        }
    }

    static func get(id: String, cachePolicy: CachePolicy = .default, completion: @escaping ((Document?, Error?) -> Void)) {
        let documentReference: DocumentReference = Document.init(id: id).documentReference
        self.get(documentReference: documentReference, cachePolicy: cachePolicy, completion: completion)
    }

    static func get(documentReference: DocumentReference) -> Self? {
        return Store.shared.get(documentType: self, reference: documentReference)
    }

    static func listen(id: String, includeMetadataChanges: Bool = true, completion: @escaping ((Document?, Error?) -> Void)) -> Disposer {
        let listenr: ListenerRegistration = Document.collectionReference.document(id).addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let document: Document = Document(snapshot: snapshot!) else {
                completion(nil, DocumentError.invalidData)
                return
            }
            completion(document, nil)
        }
        return Disposer(.value(listenr))
    }
}
