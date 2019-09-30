//
//  UserView.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/09/18.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI

struct UserView: View {

    @ObservedObject var user: User

    @State var isPresented: Bool = false

    var body: some View {

        VStack {
            Text(user[\.name])
        }
        .navigationBarTitle(Text("User"))
        .navigationBarItems(trailing: Button("Edit") {
            self.isPresented.toggle()
        })
        .sheet(isPresented: $isPresented) {
            UserEditView(user: self.user.copy(), isPresented: self.$isPresented)
        }
        .onAppear {
            _ = self.user.listen()
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: User())
    }
}
