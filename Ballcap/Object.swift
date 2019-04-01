//
//  Object.swift
//  Ballcap
//
//  Created by 1amageek on 2019/03/27.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import FirebaseFirestore


//open class Object: NSObject, Document {
//
//    open class var modelVersion: String {
//        return "1"
//    }
//
//    open class var modelName: String {
//        return String(describing: Mirror(reflecting: self).subjectType).components(separatedBy: ".").first!.lowercased()
//    }
//
//    open class var path: String {
//        return "version/\(self.modelVersion)/\(self.modelName)"
//    }
//
//    open class var reference: CollectionReference {
//        return Firestore.firestore().collection(self.path)
//    }
//
//    open var id: String {
//        return self.reference.documentID
//    }
//
//    open var path: String {
//        return self.reference.path
//    }
//
//    public var reference: DocumentReference!
//
//    public var createdAt: Timestamp = Timestamp(date: Date())
//
//    public var updatedAt: Timestamp = Timestamp(date: Date())
//
//    override init() {
//        super.init()
////        self.reference = type(of: self).reference.document()
//    }
//
//    init(id: String) {
//        super.init()
////        self.reference = type(of: self).reference.document()
//    }
//
////    required public convenience override init() {
////        super.init()
////        self.reference = type(of: self).reference.document()
////    }
////
////    required public convenience init(id: String) {
////        super.init()
////        self.reference = type(of: self).reference.document(id)
////    }
//
//}
