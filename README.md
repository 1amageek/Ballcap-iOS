# Ballcap-iOS

Ballcap is the next generation Cloud Firestore design framework. It is possible to hold a Document more flexibly than [Pring](https://github.com/1amageek/Pring). 
Ballcap is based on WriteBatch database operations. Also, like Pring, it supports DataSource and File.

[Please donate to continue development.](https://gum.co/lNNIn)

<img src="https://github.com/1amageek/pls_donate/blob/master/kyash.jpg" width="180">

### Feature

- [x] Swift Codable
- [x] Local cache
- [ ] DataSource
- [ ] File

```swift
struct Model: Codable, Equatable, Documentable {
    let number: Int = 0
    let string: String = "Ballcap"
}

let document: Document<Model> = Document()

print(document.data?.number) // 0
print(document.data?.string) // "Ballcap"

// MARK: - SAVE

// save
document.save()

// WriteBatch
let writeBatch: WriteBatch = Firestore.firestore().batch()
writeBatch.set(document: document)
writeBatch.commit()
```
