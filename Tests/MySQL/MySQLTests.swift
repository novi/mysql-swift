//
//  MySQLTests.swift
//  MySQLTests
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL
@testable import SQLFormatter

/*
 
struct TestConstants: TestConstantsType {
    let host: String = ""
    let port: Int = 3306
    let user: String = ""
    let password: String = ""
    let database: String = "test"
    let tableName: String = "unit_test_db_3894" // Unit test creates a table
    let encoding: Connection.Encoding = .UTF8MB4
    let timeZone: Connection.TimeZone = Connection.TimeZone(GMTOffset: 60 * 60 * 9) // JST
}

*/

struct DummyConstants: TestConstantsType {
    let host: String = "127.0.0.1"
    let port: Int = 3306
    let user: String = "root"
    let password: String = ""
    let database: String = "test"
    let tableName: String = "unit_test_db_3894"
    let encoding: Connection.Encoding = .UTF8MB4
    let timeZone: Connection.TimeZone = Connection.TimeZone(GMTOffset: 60 * 60 * 9) // JST
}

protocol TestConstantsType: ConnectionOption {
    var tableName: String { get }
}

protocol MySQLTestType: class {
    var constants: TestConstantsType! { get set }
    var pool: ConnectionPool! { get set }
}

extension MySQLTestType {
    func prepare() {
        self.constants = DummyConstants() // !!! Replace with your MySQL connection !!!
        self.pool = ConnectionPool(options: constants)
        
        XCTAssertEqual(constants.timeZone, Connection.TimeZone(GMTOffset: 60 * 60 * 9), "test MySQL's timezone should be JST")
    }
}

extension XCTestCase {
    var queryOption: QueryParameterOption {
        return QueryParameterOption(timeZone: Connection.TimeZone(GMTOffset: 0))
    }
}

