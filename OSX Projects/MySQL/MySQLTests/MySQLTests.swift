//
//  MySQLTests.swift
//  MySQLTests
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

/*
// You need `Constants.swift` includes `TestConstants`

struct TestConstants: TestConstantsType {
    let host: String = ""
    let port: Int = 3306
    let user: String = ""
    let password: String = ""
    let database: String = "test"
    let tableName: String = "unit_test_db_3894"
}

*/

protocol TestConstantsType {
    var host: String { get }
    var port: Int { get }
    var user: String { get }
    var password: String { get }
    var database: String { get }
    var tableName: String { get }
}


class MySQLTests: XCTestCase {
    
    var constants: TestConstantsType!
    
    override func setUp() {
        super.setUp()
        
        self.constants = TestConstants()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func createConnection() -> MySQL.Connection {
        let tz = Connection.TimeZone(GMTOffset: 60 * 60 * 9) // JST
        let options = Connection.Options(host: constants.host, port: constants.port, userName: constants.user, password: constants.password, database: constants.database, timeZone: tz)
        return Connection(options: options)
    }
}
