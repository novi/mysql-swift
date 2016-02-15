import XCTest

extension DateTests {
    var allTests : [(String, () throws -> Void)] {
        return [
            ("testSQLDate", testSQLDate),
            ("testSQLCalendar", testSQLCalendar)
        ]
    }
}

extension EscapeTests {
    var allTests : [(String, () throws -> Void)] {
        return [
            ("testStringEscape", testStringEscape),
            ("testBasicTypes", testBasicTypes),
            ("testArrayType", testArrayType),
            ("testDictionary", testDictionary),
        ]
    }
}

extension ConnectionPoolTests {
    var allTests : [(String, () throws -> Void)] {
        return [
            ("testGetConnection", testGetConnection),
            ("testExecutionBlock", testExecutionBlock)
        ]
    }
}

extension ConnectionTests {
    var allTests : [(String, () throws -> Void)] {
        return [
            ("testConnect", testConnect),
            ("testConnect2", testConnect2)
        ]
    }
}

extension QueryFormatterTests {
    var allTests : [(String, () throws -> Void)] {
        return [
            ("testBasicFormatting", testBasicFormatting),
            ("testPlaceholder", testPlaceholder)
        ]
    }
}

extension QueryTests {
    var allTests : [(String, () throws -> Void)] {
        return [
            ("testInsertRow", testInsertRow),
            ("testSelectingWithFieldKey", testSelectingWithFieldKey)
        ]
    }
}


XCTMain([
    DateTests(),
    EscapeTests(),
    QueryFormatterTests(),
    
    ConnectionPoolTests(),
    ConnectionTests(),
    QueryTests()
])