//
//  DataListenable.swift
//  Ballcap
//
//  Created by 1amageek on 2019/09/18.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore


public protocol DataListenable: AnyObject {

    var listener: ListenerRegistration? { get set }
}

public extension DataListenable where Self: DataRepresentable, Self: Object {

    @discardableResult
    func listen(includeMetadataChanges: Bool = true, completion: ((Self?, Error?) -> Void)? = nil) -> Self {
        if listener != nil {
            return self
        }
        self.listener = self.documentReference.addSnapshotListener(includeMetadataChanges: includeMetadataChanges) { [weak self] (snapshot, error) in
            if let error = error {
                completion?(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion?(nil, nil)
                return
            }
            do {
                try self?._set(snapshot: snapshot)
                guard let self = self else { return }
                completion?(self, nil)
            } catch (let error) {
                completion?(nil, error)
            }
        }
        return self
    }
}
