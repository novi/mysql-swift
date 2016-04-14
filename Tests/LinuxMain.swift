import XCTest
@testable import MySQLTestSuite
@testable import SQLFormatterTestSuite

XCTMain([
            testCase( DateTests.allTests ),
            testCase( EscapeTests.allTests ),
            testCase( QueryFormatterTests.allTests ),
            testCase( ConnectionPoolTests.allTests ),
            testCase( ConnectionTests.allTests ),
            testCase( QueryTests.allTests ),
            testCase( BlobQueryTests.allTests ),
            
            
            testCase( SQLFormatterTests.allTests )
    ])