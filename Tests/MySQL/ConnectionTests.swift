//
//  ConnectionTest.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

extension ConnectionTests {
    static var allTests : [(String, (ConnectionTests) -> () throws -> Void)] {
        return [
                   ("testConnect", testConnect),
                   ("testConnect2", testConnect2)
        ]
    }
}

class ConnectionTests: XCTestCase, MySQLTestType {
    
    var constants: TestConstantsType!
    var pool: ConnectionPool!

    override func setUp() {
        super.setUp()
        
        prepare()
    }
    
    func testConnect() throws {
        let conn = try pool.getConnection()
        XCTAssertTrue(conn.ping)
    }
    
    func testConnect2() throws {
        let conn = try pool.getConnection()
        try conn.query("SELECT 1;" as String)
        XCTAssertTrue(conn.ping)
    }
}