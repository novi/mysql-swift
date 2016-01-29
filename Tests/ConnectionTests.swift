//
//  ConnectionTest.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

class ConnectionTests: MySQLTests {
    
    func testConnect() {
        let conn = try! pool.getConnection()
        XCTAssertTrue(conn.isConnected)
    }
    
    func testConnect2() {
        let conn = try! pool.getConnection()
        try! conn.query("SELECT 1;")
        XCTAssertTrue(conn.isConnected)
    }
}