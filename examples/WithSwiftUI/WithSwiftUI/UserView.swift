//
//  UserView.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/09/18.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI
import Ballcap

struct UserView: View {

    @ObservedObject var user: User

    @State var isPresented: Bool = false

    var body: some View {

        VStack {
            
            (user[\.profileImage] ?? File(user.storageReference))
                .resizable()
                .renderingMode(.original)
                .frame(width: 120, height: 120)
                .background(Color.gray)
                .clipShape(Circle())
                .padding()

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
            self.user.listen()
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: User())
    }
}
