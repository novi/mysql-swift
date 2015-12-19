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
        let conn = createConnection()
        try! conn.connect()
        XCTAssertTrue(conn.isConnected)
    }
    
    func testAutoConnect() {
        let conn = createConnection()
        try! conn.query("SELECT 1;")
        XCTAssertTrue(conn.isConnected)
    }
}