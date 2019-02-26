import XCTest

extension BlobQueryTests {
    static let __allTests = [
        ("testBlobAndTextOnBinCollation", testBlobAndTextOnBinCollation),
        ("testEscapeBlob", testEscapeBlob),
        ("testInsertForCombinedUnicodeCharacter", testInsertForCombinedUnicodeCharacter),
        ("testJSONColumnValue", testJSONColumnValue),
    ]
}

extension ConnectionPoolTests {
    static let __allTests = [
        ("testExecutionBlock", testExecutionBlock),
        ("testGetConnection", testGetConnection),
        ("testThreadingConnectionPool", testThreadingConnectionPool),
    ]
}

extension ConnectionTests {
    static let __allTests = [
        ("testConnect2", testConnect2),
        ("testConnect", testConnect),
        ("testDefaultConnectionOption", testDefaultConnectionOption),
    ]
}

extension DateTests {
    static let __allTests = [
        ("testDateComponents", testDateComponents),
        ("testSQLCalendar", testSQLCalendar),
        ("testSQLDate", testSQLDate),
    ]
}

extension EscapeTests {
    static let __allTests = [
        ("testArrayType", testArrayType),
        ("testAutoincrement", testAutoincrement),
        ("testBasicTypes", testBasicTypes),
        ("testDictionary", testDictionary),
        ("testNestedArray", testNestedArray),
        ("testStringEscape", testStringEscape),
    ]
}

extension QueryDecimalTypeTests {
    static let __allTests = [
        ("testDecimalType_largerValue", testDecimalType_largerValue),
        ("testDecimalType", testDecimalType),
    ]
}

extension QueryFormatterTests {
    static let __allTests = [
        ("testBasicFormatting", testBasicFormatting),
        ("testLikeEscape", testLikeEscape),
        ("testPlaceholder", testPlaceholder),
        ("testStringUtil", testStringUtil),
    ]
}

extension QueryParameterTests {
    static let __allTests = [
        ("testAutoincrementType", testAutoincrementType),
        ("testCodableIDType_AutoincrementNoID", testCodableIDType_AutoincrementNoID),
        ("testCodableIDType", testCodableIDType),
        ("testDataAndURLType", testDataAndURLType),
        ("testDateComponentsType", testDateComponentsType),
        ("testDecimalType", testDecimalType),
        ("testEnumType", testEnumType),
        ("testIDType", testIDType),
        ("testIDTypeInContainer", testIDTypeInContainer),
    ]
}

extension QueryTests {
    static let __allTests = [
        ("testBulkInsert", testBulkInsert),
        ("testEmojiInserting", testEmojiInserting),
        ("testInsertRowCodable", testInsertRowCodable),
        ("testTransaction", testTransaction),
    ]
}

extension QueryURLTypeTests {
    static let __allTests = [
        ("testURLInvalid", testURLInvalid),
        ("testURLType", testURLType),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(BlobQueryTests.__allTests),
        testCase(ConnectionPoolTests.__allTests),
        testCase(ConnectionTests.__allTests),
        testCase(DateTests.__allTests),
        testCase(EscapeTests.__allTests),
        testCase(QueryDecimalTypeTests.__allTests),
        testCase(QueryFormatterTests.__allTests),
        testCase(QueryParameterTests.__allTests),
        testCase(QueryTests.__allTests),
        testCase(QueryURLTypeTests.__allTests),
    ]
}
#endif
