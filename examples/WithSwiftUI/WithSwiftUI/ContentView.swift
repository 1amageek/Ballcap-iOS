//
//  ContentView.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/07/14.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI
import Firebase
import Ballcap

struct ContentView : View {

    @State var users: [User] = []

    var dataSource: DataSource<User> = User.query.dataSource()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.users) { user in
                    NavigationLink(destination: UserView(user: user)) {
                        HStack {
                            (user[\.profileImage] ?? File(user.storageReference))
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 60, height: 60)
                                .background(Color.gray)
                                .clipShape(Circle())
                                .padding()
                            Text(user[\.name])
                        }
                    }
                }.onDelete(perform: delete)
            }
            .navigationBarTitle(Text("Users"))
            .navigationBarItems(trailing: Button("Add") {
                let user: User = User()
                user[\.name] = UUID().uuidString
                user.save()
            })
        }.onAppear {
            self.dataSource.onChanged { (_, snapshot) in
                self.users = snapshot.after
            }.get()
        }
    }

    func delete(at offset: IndexSet) {
        if let first = offset.first {
            let user: User = self.users[first]
            user.delete()
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        if FirebaseApp.app() != nil {
            FirebaseApp.configure()
        }
        return ContentView()
    }
}
#endif
