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
