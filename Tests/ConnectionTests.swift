//
//  ConnectionTest.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

class ConnectionTests: XCTestCase, MySQLTestType {
    
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    #if os(OSX)
    override func setUp() {
        super.setUp()
        
        prepare()
    }
    #else
    func setUp() {
        prepare()
    }
    #endif
    
    func testConnect() {
        let conn = try! pool.getConnection()
        XCTAssertTrue(conn.ping)
    }
    
    func testConnect2() {
        let conn = try! pool.getConnection()
        try! conn.query("SELECT 1;")
        XCTAssertTrue(conn.ping)
    }
}