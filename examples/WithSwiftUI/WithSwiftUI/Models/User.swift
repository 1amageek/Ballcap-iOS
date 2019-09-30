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
    }

    @Published var data: User.Model?

    var listener: ListenerRegistration?
}
