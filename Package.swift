// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Ballcap-iOS",
    platforms: [.iOS(.v11), .macOS(.v10_15)],
    products: [
        .library(
            name: "Ballcap-iOS",
            targets: ["Ballcap-iOS"]),
    ],
    dependencies: [
        .package(
          name: "Firebase",
          url: "https://github.com/firebase/firebase-ios-sdk.git",
          .branch("6.33-spm-beta")),
    ],
    targets: [
        .target(
            name: "Ballcap-iOS",
            dependencies: [
               .product(name: "FirebaseFirestore", package: "Firebase"),
               .product(name: "FirebaseStorage", package: "Firebase"),
               .product(name: "FirebaseFirestoreSwift", package: "Firebase"),
            ]),
        .testTarget(
            name: "Ballcap-iOSTests",
            dependencies: [
              "Ballcap-iOS",
               .product(name: "FirebaseFirestore", package: "Firebase"),
               .product(name: "FirebaseStorage", package: "Firebase"),
               .product(name: "FirebaseFirestoreSwift", package: "Firebase"),
            ]),
    ]
)
