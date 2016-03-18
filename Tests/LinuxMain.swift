import XCTest
#if os(Linux)
    @testable import MySQLtest
XCTMain([
            DateTests(),
            EscapeTests(),
            QueryFormatterTests(),
            ConnectionPoolTests(),
            ConnectionTests(),
            QueryTests(),
            BlobQueryTests()
    ])
#else
    @testable import MySQLTestSuite
XCTMain([
            testCase( DateTests.allTests ),
            testCase( EscapeTests.allTests ),
            testCase( QueryFormatterTests.allTests ),
            testCase( ConnectionPoolTests.allTests ),
            testCase( ConnectionTests.allTests ),
            testCase( QueryTests.allTests ),
            testCase( BlobQueryTests.allTests )
    ])
#endif