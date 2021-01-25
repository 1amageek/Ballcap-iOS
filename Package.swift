// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Ballcap",
    platforms: [.iOS(.v11), .macOS(.v10_12)],
    products: [
        .library(
            name: "Ballcap",
            targets: ["Ballcap"]),
    ],
    dependencies: [
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "7.4.0"))
    ],
    targets: [
        .target(
            name: "Ballcap",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase"),
                .product(name: "FirebaseFirestoreSwift", package: "Firebase")
            ]
        ),
        .testTarget(
            name: "BallcapTests",
            dependencies: [
                "Ballcap",
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase"),
                .product(name: "FirebaseFirestoreSwift", package: "Firebase")
            ]
        )
    ]
)
