    import XCTest
    import Firebase
    @testable import Ballcap

    final class FirebaseTest {

        static let shared: FirebaseTest = FirebaseTest()

        init () {
            let url: URL = Bundle.module.url(forResource: "GoogleService-Info", withExtension: "plist")!
            let options: FirebaseOptions = FirebaseOptions(contentsOfFile: url.path)!
            FirebaseApp.configure(options: options)
        }
    }

    final class BallcapTests: XCTestCase {
        func testExample() {
            print("Test Start")
        }
    }
