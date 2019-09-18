//
//  UserEditView.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/09/18.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI

struct UserEditView: View {

    @ObservedObject var user: User

    @Binding var isPresented: Bool

    var body: some View {

        VStack {

            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $user[\.name])
                }
            }

            Button("Save") {
                self.user.update()
                self.isPresented.toggle()
            }
        }.frame(height: 200)
    }
}

struct UserEditView_Previews: PreviewProvider {
    static var previews: some View {
        UserEditView(user: User(), isPresented: .constant(false))
    }
}
