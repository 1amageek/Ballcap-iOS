//
//  UserEditView.swift
//  WithSwiftUI
//
//  Created by 1amageek on 2019/09/18.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import SwiftUI
import Ballcap

struct UserEditView: View {

    @ObservedObject var user: User

    @Binding var isPresented: Bool

    @State var isPresenting: Bool = false

    var body: some View {

        VStack {

            Button(action: {
                self.isPresenting.toggle()
            }) {
                (user[\.profileImage] ?? File(user.storageReference))
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 120, height: 120)
                    .background(Color.gray)
                    .clipShape(Circle())
                    .padding()
            }

            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $user[\.name])
                }
            }

            Button("Save") {

                if self.user.files.isEmpty {
                    self.user.update()
                    self.isPresented.toggle()
                } else {
                    let storageBatch: StorageBatch = StorageBatch()
                    storageBatch.save(self.user.files)
                    storageBatch.commit { (error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        self.user.files = []
                        self.user.update()
                        self.isPresented.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: self.$isPresenting) {
            ImagePicker { data in
                let file: File = File(self.user.storageReference, data: data, mimeType: .jpeg)
                self.user.files.append(file)
                self.user.data?.profileImage = file
            }
        }
    }
}

struct UserEditView_Previews: PreviewProvider {
    static var previews: some View {
        UserEditView(user: User(), isPresented: .constant(false))
    }
}
