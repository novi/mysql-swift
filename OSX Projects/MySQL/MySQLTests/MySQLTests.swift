//
//  MySQLTests.swift
//  MySQLTests
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import CoreFoundation
import XCTest
@testable import MySQL

// 

class MySQLTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    // https://github.com/felixge/node-mysql/blob/master/test/unit/protocol/test-SqlString.js
    func testEscape() {
        XCTAssertEqual(SQLString.escapeString("Sup'er"), "'Sup\\'er'")
    
        
    }
    
    func testSQLDate() {
        let expected = "2003-01-02 03:04:05"
        let date = SQLDate(absoluteTime: 63169445)
        XCTAssertEqual(date.escapedValue(), "'\(expected)'")
        
        let sqlDate = try! SQLDate(sqlDate: expected, timeZoneOffset: 60*60*9)
        XCTAssertEqual(sqlDate.absoluteTime, 63169445 - 60*60*9, "create date from sql string")
        XCTAssertEqual(sqlDate.escapedValue(), "'\(expected)'")
        
        let sqlYear = try! SQLDate(sqlDate: "2021")
        XCTAssertEqual(sqlYear.escapedValue(), "'2021-01-01 00:00:00'")
    }
}
