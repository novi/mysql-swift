#if os(Linux)

import XCTest
@testable import MySQLtest

XCTMain([
    DateTests(),
    EscapeTests(),
    QueryFormatterTests(),
    
    
    ConnectionPoolTests(),
    ConnectionTests(),
    QueryTests()
])

#endif
