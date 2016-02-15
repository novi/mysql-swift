//
//  ConnectionPoolTests.swift
//  MySQL
//
//  Created by ito on 12/24/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

class ConnectionPoolTests: XCTestCase, MySQLTestType {

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

    func testGetConnection() {
        
        let initialConnection = 1
        
        XCTAssertEqual(pool.pool.count, initialConnection)
        XCTAssertEqual(pool.inUseConnections, 0)
        
        var connections: [Connection] = []
        for _ in 0..<initialConnection {
            let con = try! pool.getConnection()
            connections.append(con)
        }
        XCTAssertEqual(connections.count, initialConnection)
        XCTAssertEqual(pool.inUseConnections, initialConnection)
        
        // increse initial connections
        pool.initialConnections = 7
        XCTAssertEqual(pool.pool.count, 7)
        
        // get connection while max connections count
        while connections.count < pool.maxConnections {
            let con = try! pool.getConnection()
            connections.append(con)
        }
        
        XCTAssertEqual(connections.count, pool.maxConnections)
        XCTAssertEqual(pool.pool.count, pool.maxConnections)
        XCTAssertEqual(pool.inUseConnections, pool.maxConnections)
        
        let failureConn = try? pool.getConnection() // this connection getting failure
        XCTAssertNil(failureConn)
        
        for c in connections {
            // release connections that we have got
            c.release()
        }
        connections.removeAll()
        XCTAssertEqual(pool.inUseConnections, 0)
        XCTAssertEqual(pool.pool.count, pool.maxConnections)
    }
    
    
    func testExecutionBlock() {
        
        var thisConn: Connection!
        try! pool.execute { conn in
            thisConn = conn
            XCTAssertEqual(conn.isInUse, true)
            try conn.query("SELECT 1 + 2;")
        }
        XCTAssertEqual(thisConn.isInUse, false)
    }
    
}
