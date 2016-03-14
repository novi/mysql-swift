import XCTest
@testable import MySQLTestSuite

XCTMain([
    testCase( DateTests.allTests ),
    testCase( EscapeTests.allTests ),
    testCase( QueryFormatterTests.allTests ),
    
    
    testCase( ConnectionPoolTests.allTests ),
    testCase( ConnectionTests.allTests ),
    testCase( QueryTests.allTests )
])
