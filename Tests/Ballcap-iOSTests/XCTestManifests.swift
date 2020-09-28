import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Ballcap_iOSTests.allTests),
    ]
}
#endif
