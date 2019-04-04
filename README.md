# Ballcap-iOS

 [![Version](http://img.shields.io/cocoapods/v/Ballcap.svg)](http://cocoapods.org/?q=Pring)
 [![Platform](http://img.shields.io/cocoapods/p/Ballcap.svg)](http://cocoapods.org/?q=Pring)
 [![Downloads](https://img.shields.io/cocoapods/dt/Ballcap.svg?label=Total%20Downloads&colorB=28B9FE)](https://cocoapods.org/pods/Ballcap)

Ballcap is the next generation Cloud Firestore design framework. It is possible to hold a Document more flexibly than [Pring](https://github.com/1amageek/Pring). 
Ballcap is based on WriteBatch database operations. Also, like Pring, it supports DataSource and File.

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
batch.commit()
```

You can get data by using the get function.
> note: The callback may be called twice to access the cache within the get function.

```swift
Document<Model>.get(id: "DOCUMENT_ID", completion: { (document, error) in
    print(document.data)
})
```

If you do not want to use the cache, do the following:

```swift
Document<Model>.get(id: "DOCUMENT_ID", cachePolicy: .networkOnly) { (document, error) in
    print(document.data)
}
```

It is also possible to access the cache without using the network.

```swift
let document: Document<Model> = Document()
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
