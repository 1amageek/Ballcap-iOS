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

    @State var isPresenting: Bool = false

    var body: some View {

        VStack {
            Text(user[\.name])
        }
        .navigationBarTitle(Text("User"))
        .navigationBarItems(trailing: Button("Edit") {
            self.isPresenting.toggle()
        })
        .sheet(isPresented: $isPresenting) {
            UserEditView(user: self.user.copy(), isPresented: self.$isPresenting)
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
