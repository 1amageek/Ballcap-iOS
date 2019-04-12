# 🧢 Ballcap-iOS

 [![Version](http://img.shields.io/cocoapods/v/Ballcap.svg)](http://cocoapods.org/?q=Pring)
 [![Platform](http://img.shields.io/cocoapods/p/Ballcap.svg)](http://cocoapods.org/?q=Pring)
 [![Downloads](https://img.shields.io/cocoapods/dt/Ballcap.svg?label=Total%20Downloads&colorB=28B9FE)](https://cocoapods.org/pods/Ballcap)

Ballcap is the next generation Cloud Firestore design framework. It is possible to hold a Document more flexibly than [Pring](https://github.com/1amageek/Pring). 
Ballcap is based on WriteBatch database operations. Also, like Pring, it supports DataSource and File.

Inspired by https://github.com/firebase/firebase-ios-sdk/tree/pb-codable3

[Please donate to continue development.](https://gum.co/lNNIn)

<img src="https://github.com/1amageek/pls_donate/blob/master/kyash.jpg" width="180">

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
struct Model: Codable, Equatable, Modalable {
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
> note: The callback may be called twice to access the cache within the get function.

```swift
Document<Model>.get(id: "DOCUMENT_ID", completion: { (document, error) in
    print(document.data)
})
```

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

    var data: Firebase.Pass.Model?

    struct Model: Modelable & Codable & ItemProtocol {
        var members: [String] = []
    }
}
```

__SubCollection__

Ballcap has discontinued NestedCollection and ReferenceCollection Class. Instead, it represents SubCollection by defining CollectionKeys.

Class must match `HierarchicalStructurable` to use CollectionKeys.
```swift
class Room: Object, DataRepresentable & HierarchicalStructurable {

    var data: Firebase.Pass.Model?

    struct Model: Modelable & Codable & ItemProtocol {
        var members: [String] = []
    }

    enum CollectionKeys: String {
        case transcripts
    }
}
```

Use the collection function to access the SubCollection.
```swift
let collectionReference: CollectionReference = obj.collection(path: .subCollectionPath)
```

