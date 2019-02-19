import XCTest

extension SQLFormattingTests {
    static let __allTests = [
        ("testDummy", testDummy),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SQLFormattingTests.__allTests),
    ]
}
#endif
