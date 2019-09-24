# 🧢 Ballcap-iOS

<img src="https://github.com/1amageek/Ballcap-iOS/blob/master/Ballcap.png" width="100%">

 [![Version](http://img.shields.io/cocoapods/v/Ballcap.svg)](http://cocoapods.org/?q=Pring)
 [![Platform](http://img.shields.io/cocoapods/p/Ballcap.svg)](http://cocoapods.org/?q=Pring)
 [![Downloads](https://img.shields.io/cocoapods/dt/Ballcap.svg?label=Total%20Downloads&colorB=28B9FE)](https://cocoapods.org/pods/Ballcap)

Ballcap is a database schema design framework for Cloud Firestore.

__Why Ballcap__

Cloud Firestore is a great schema-less and flexible database that can handle data. However, its flexibility can create many bugs in development. Ballcap can assign schemas to Cloud Firestore to visualize data structures. This plays a very important role when developing as a team.

Inspired by https://github.com/firebase/firebase-ios-sdk/tree/pb-codable3

[Please donate to continue development.](https://gum.co/lNNIn)

<img src="https://github.com/1amageek/pls_donate/blob/master/kyash.jpg" width="180">

- Ballcap for TypeScript: https://github.com/1amageek/ballcap.ts

__Sameple projects__

- [Messagestore](https://github.com/1amageek/Messagestore)  Chat framework created by Cloud Firestore.

### Feature

☑️ Firestore's document schema with Swift Codable<br>
☑️ Of course type safety.<br>
☑️ It seamlessly works with Firestore and Storage.<br>

## Requirements ❗️
- iOS 10 or later
- Swift 5.0 or later
- [Firebase firestore](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase storage](https://firebase.google.com/docs/storage/ios/start)

## Installation ⚙
#### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod 'Ballcap' ` to your Podfile.
- Run `pod install`.

If you have a Feature Request, please post an [issue](https://github.com/1amageek/Ballcap/issues/new).

## Usage

### Document scheme

You must conform to the Codable and Modelable protocols to define Scheme.

```swift
struct Model: Codable, Equatable, Modelable {
    var number: Int = 0
    var string: String = "Ballcap"
}
```

### Initialization

The document is initialized as follows:

```swift

let document: Document<Model> = Document()

print(document.data?.number) // 0
print(document.data?.string) // "Ballcap"

// KeyPath
print(document[\.number]) // 0
print(document[\.string]) // "Ballcap"
```

### RootReference

Considering the extensibility of DB, it is recommended to provide a method of version control.

```swift
// in AppDelegate
FirebaseApp.configure()
BallcapApp.configure(Firestore.firestore().document("version/1"))
```

### CRUD

Ballcap has a cache internally.When using the cache, use `Batch` instead of `WriteBatch`.

```swift
// save
document.save()

// update
document.update()

// delete
document.delete()

// Batch
let batch: Batch = Batch()
batch.save(document: document)
batch.update(document: document)
batch.delete(document: document)
batch.commit()
```

You can get data by using the get function.

```swift
Document<Model>.get(id: "DOCUMENT_ID", completion: { (document, error) in
    print(document.data)
})
```

The next get function gets data in favor of the cache. If there is no cached data, it gets from the server.
```swift
let document: Document<Model> = Document("DOCUMENT_ID")
document.get { (document, error) in
   print(document.data)
}
```

__Why data is optional?__

In CloudFirestore, DocumentReference does not necessarily have data. There are cases where there is no data under the following conditions.

1. If no data is stored in DocumentReference.
1. If data was acquired using `Source.cache` from DocumentReference, but there is no data in cache.

Ballcap recommends that developers unwrap if they can determine that there is data.

It is also possible to access the cache without using the network.

```swift
let document: Document<Model> = Document(id: "DOCUMENT_ID")
print(document.cache?.number) // 0
print(document.cache?.string) // "Ballcap"
```

### Custom properties

Ballcap is preparing custom property to correspond to FieldValue.

__ServerTimestamp__

Property for handling `FieldValue.serverTimestamp()`

```swift
struct Model: Codable, Equatable {
    let serverValue: ServerTimestamp
    let localValue: ServerTimestamp
}
let model = Model(serverValue: .pending,
                  localValue: .resolved(Timestamp(seconds: 0, nanoseconds: 0)))
```

__IncrementableInt__ & __IncrementableDouble__

Property for handling `FieldValue.increment()`

```swift
struct Model: Codable, Equatable, Modelable {
    var num: IncrementableInt = 0
}
let document: Document<Model> = Document()
document.data?.num = .increment(1)
```

__OperableArray__

Property for handling `FieldValue.arrayRemove()`, `FieldValue.arrayUnion()`

```swift
struct Model: Codable, Equatable, Modelable {
    var array: OperableArray<Int> = [0, 0]
}
let document: Document<Model> = Document()
document.data?.array = .arrayUnion([1])
document.data?.array = .arrayRemove([1])
```

### File

File is a class for accessing Firestorage.
You can save Data in the same path as Document by the follow:
```swift
let document: Document<Model> = Document(id: "DOCUMENT_ID")
let file: File = File(document.storageReference)
```

File supports multiple MIMETypes. Although File infers MIMEType from the name, it is better to input MIMEType explicitly.

- [x] plain
- [x] csv
- [x] html
- [x] css
- [x] javascript
- [x] octetStream(String?)
- [x] pdf
- [x] zip
- [x] tar
- [x] lzh
- [x] jpeg
- [x] pjpeg
- [x] png
- [x] gif
- [x] mp4
- [x] custom(String, String)

#### Upload & Download

Upload and Download each return a task. You can manage your progress by accessing tasks.

```swift
// upload
let ref: StorageReference = Storage.storage().reference().child("/a")
let data: Data = "test".data(using: .utf8)!
let file: File = File(ref, data: data, name: "n", mimeType: .plain)
let task = file.save { (metadata, error) in
    
}

// download
let task = file.getData(completion: { (data, error) in
    let text: String = String(data: data!, encoding: .utf8)!
})
```

#### StorageBatch

StorageBatch is used when uploading multiple files to Cloud Storage.

```swift
let textData: Data = "test".data(using: .utf8)!
let textFile: File = File(Storage.storage().reference(withPath: "c"), data: textData, mimeType: .plain)
batch.save(textFile)

let jpgData: Data = image.jpegData(compressionQuality: 1)!
let jpgFile: File = File(Storage.storage().reference(withPath: "d"), jpgData: textData, mimeType: .jpeg)
batch.save(jpgFile)
batch.commit { error in

}
```

### DataSource

Ballcap provides a DataSource for easy handling of Collections and SubCollections.

##### DataSource initialize

__from Document__

```swift
let dataSource: DataSource<Item> = Document<Item>.query.dataSource()
```

__from Collection Reference__

```swift
let query: DataSource<Document<Item>>.Query = DataSource.Query(Firestore.firestore().collectionGroup("items"))
let dataSource = DataSource(reference: query)
```

__NSDiffableDataSourceSnapshot__

```swift
self.dataSource = Document<Item>.query
    .order(by: "updatedAt", descending: true)
    .limit(to: 3)
    .dataSource()
    .retrieve(from: { (snapshot, documentSnapshot, done) in
        let document: Document<Item> = Document(documentSnapshot.reference)
        document.get { (item, error) in
            done(item!)
        }
    })
    .onChanged({ (snapshot, dataSourceSnapshot) in
        var snapshot: NSDiffableDataSourceSnapshot<Section, DocumentProxy<Item>> = self.tableViewDataSource.snapshot()
        snapshot.appendItems(dataSourceSnapshot.changes.insertions.map { DocumentProxy(document: $0)})
        snapshot.deleteItems(dataSourceSnapshot.changes.deletions.map { DocumentProxy(document: $0)})
        snapshot.reloadItems(dataSourceSnapshot.changes.modifications.map { DocumentProxy(document: $0)})
        self.tableViewDataSource.apply(snapshot, animatingDifferences: true)
    })
    .listen()
```

__UITableViewDelegate, UITableViewDataSource__

```swift
self.dataSource = Document<Item>.query
    .order(by: "updatedAt", descending: true)
    .limit(to: 3)
    .dataSource()
    .retrieve(from: { (snapshot, documentSnapshot, done) in
        let document: Document<Item> = Document(documentSnapshot.reference)
        document.get { (item, error) in
            done(item!)
        }
    })
    .onChanged({ (snapshot, dataSourceSnapshot) in
        self.tableView.performBatchUpdates({
            self.tableView.insertRows(at: dataSourceSnapshot.changes.insertions.map { IndexPath(item: dataSourceSnapshot.after.firstIndex(of: $0)!, section: 0)}, with: .automatic)
            self.tableView.deleteRows(at: dataSourceSnapshot.changes.deletions.map { IndexPath(item: dataSourceSnapshot.before.firstIndex(of: $0)!, section: 0)}, with: .automatic)
            self.tableView.reloadRows(at: dataSourceSnapshot.changes.modifications.map { IndexPath(item: dataSourceSnapshot.after.firstIndex(of: $0)!, section: 0)}, with: .automatic)
        }, completion: nil)
    })
    .listen()
```

## Migrate from [Pring](https://github.com/1amageek/Pring)

### Overview
The difference from Pring is that ReferenceCollection and NestedCollection have been abolished.
In Pring, adding a child Object to the ReferenceCollection and NestedCollection of the parent Object saved the parent Object at the same time when it was saved.
Ballcap requires the developer to save SubCollection using Batch.
In addition, Pring also saved the File at the same time as the Object with the File was saved.
Ballcap requires that developers save files using StorageBatch.

### Scheme
Ballcap can handle Object class by inheriting Object class like Pring.
If you inherit Object class, you must conform to `DataRepresentable`.


```swift
class Room: Object, DataRepresentable {

    var data: Model?

    struct Model: Modelable & Codable {
        var members: [String] = []
    }
}
```

__SubCollection__

Ballcap has discontinued NestedCollection and ReferenceCollection Class. Instead, it represents SubCollection by defining CollectionKeys.

Class must match `HierarchicalStructurable` to use CollectionKeys.
```swift
class Room: Object, DataRepresentable & HierarchicalStructurable {

    var data: Model?
    
    var transcripts: [Transcript] = []

    struct Model: Modelable & Codable {
        var members: [String] = []
    }

    enum CollectionKeys: String {
        case transcripts
    }
}
```

Use the collection function to access the SubCollection.
```swift
let collectionReference: CollectionReference = obj.collection(path: .transcripts)
```

SubCollection's Document save
```swift
let batch: Batch = Batch()
let room: Room = Room()
batch.save(room.transcripts, to: room.collection(path: .transcripts))
batch.commit()
```


## Using Ballcap with SwiftUI

First, create an object that conforms to `ObservableObject`.
`DataListenable` makes an Object observable.

```swift
final class User: Object, DataRepresentable, DataListenable, ObservableObject, Identifiable {

    typealias ID = String

    override class var name: String { "users" }

    struct Model: Codable, Modelable {

        var name: String = ""
    }

    @Published var data: User.Model?

    var listener: ListenerRegistration?
}
```

Next, create a `View` that displays this object.


```swift
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
```

You can access the object data using `subscript`.

```swift
Text(user[\.name])
```

Start user observation with `onAppear`.

```swift
.onAppear {
    _ = self.user.listen()
}
```

### Copy object

Pass a copy of Object to EditView before editing the data.

```swift
.sheet(isPresented: $isPresented) {
    UserEditView(user: self.user.copy(), isPresented: self.$isPresented)
}
```

Since the Object is being observed by the listener, changes can be caught automatically.

Finally, create a view that can update the object.

```swift
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
```

Updating an object is possible only with `update()`.

```swift
Button("Update") {
    self.user.update()
    self.isPresented.toggle()
}
```
