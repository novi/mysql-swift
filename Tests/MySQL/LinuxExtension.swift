import XCTest

extension DateTests {
    static var allTests : [(String, DateTests -> () throws -> Void)] {
        return [
            ("testSQLDate", testSQLDate),
            ("testSQLCalendar", testSQLCalendar)
        ]
    }
}

extension EscapeTests {
    static var allTests : [(String, EscapeTests -> () throws -> Void)] {
        return [
            ("testStringEscape", testStringEscape),
            ("testBasicTypes", testBasicTypes),
            ("testArrayType", testArrayType),
            ("testDictionary", testDictionary),
        ]
    }
}

extension ConnectionPoolTests {
    static var allTests : [(String, ConnectionPoolTests -> () throws -> Void)] {
        return [
            ("testGetConnection", testGetConnection),
            ("testExecutionBlock", testExecutionBlock)
        ]
    }
}

extension ConnectionTests {
    static var allTests : [(String, ConnectionTests -> () throws -> Void)] {
        return [
            ("testConnect", testConnect),
            ("testConnect2", testConnect2)
        ]
    }
}

extension QueryFormatterTests {
    static var allTests : [(String, QueryFormatterTests -> () throws -> Void)] {
        return [
            ("testBasicFormatting", testBasicFormatting),
            ("testPlaceholder", testPlaceholder)
        ]
    }
}

extension QueryTests {
    static var allTests : [(String, QueryTests -> () throws -> Void)] {
        return [
            ("testInsertRow", testInsertRow),
            ("testEmojiInserting", testEmojiInserting)
        ]
    }
}

extension BlobQueryTests {
    static var allTests : [(String, BlobQueryTests -> () throws -> Void)] {
        return [
                   ("testInsertForCombinedUnicodeCharacter", testInsertForCombinedUnicodeCharacter)
        ]
    }
}
