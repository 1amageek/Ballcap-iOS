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

    @ObservedObject (initialValue: ItemDatabase()) var dataSource: ItemDatabase
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.dataSource.items, id: \.id) { item in
                    ItemRow(item: item.data!)
                }.onDelete(perform: delete)
            }
            .navigationBarTitle(Text("Item"))
                .navigationBarItems(trailing: Button("Add", action: {
                    let item: Document<Item> = Document()
                    item.data?.title = UUID().uuidString
                    item.data?.body = "\(Date())"
                    item.save()
                }))
        }
    }

    func delete(at offset: IndexSet) {
        if let first = offset.first {
            let item: Document<Item> = self.dataSource.items[first]
            item.delete()
        }
    }
}

struct ItemRow : View {

    var item: Item

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title ?? "").bold()
            Text(item.body ?? "")
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
