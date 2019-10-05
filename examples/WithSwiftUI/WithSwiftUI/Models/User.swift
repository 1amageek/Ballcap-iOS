//
//  User.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/09/18.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import Ballcap
import Firebase
import SwiftUI

final class User: Object, DataRepresentable, DataListenable, ObservableObject, Identifiable {

    typealias ID = String

    override class var name: String { "users" }

    struct Model: Codable, Modelable {

        var name: String = ""

        var profileImage: File?
    }

    @Published var data: User.Model?

    var listener: ListenerRegistration?

    var files: [File] = []

    func load(keyPath: WritableKeyPath<Model, File?>) {
        print("load")
        if let file: File = self.data?[keyPath: keyPath] {
            if file.data == nil {
                print("no data")
                if file.downloadTask == nil {
                    print("get")
                    file.getData { (data, error) in
                        print("data", data)
                        self[keyPath] = file
                    }
                }
            } else {
                print("have data")
                self[keyPath] = file
            }

        }
    }

    func cancel(_ keyPath: WritableKeyPath<Model, File?>) {
        if let file: File = self.data?[keyPath: keyPath] {
            file.downloadTask?.cancel()
        }
    }
}
