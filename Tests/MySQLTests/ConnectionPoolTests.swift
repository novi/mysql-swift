//
//  ConnectionPoolTests.swift
//  MySQL
//
//  Created by ito on 12/24/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Foundation
import Dispatch
import XCTest
@testable import MySQL

extension ConnectionPoolTests {
    static var allTests : [(String, (ConnectionPoolTests) -> () throws -> Void)] {
        return [
                   ("testGetConnection", testGetConnection),
                   ("testExecutionBlock", testExecutionBlock),
                   ("testThreadingConnectionPool", testThreadingConnectionPool)
        ]
    }
}

class ConnectionPoolTests: XCTestCase, MySQLTestType {

    
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
    }

    func testGetConnection() throws {
        
        let initialConnection = 1
        
        XCTAssertEqual(pool.pool.count, initialConnection)
        XCTAssertEqual(pool.inUseConnections, 0)
        
        var connections: [Connection] = []
        for _ in 0..<initialConnection {
            let con = try pool.getConnection()
            connections.append(con)
        }
        XCTAssertEqual(connections.count, initialConnection)
        XCTAssertEqual(pool.inUseConnections, initialConnection)
        
        // increse initial connections
        pool.initialConnections = 7
        XCTAssertEqual(pool.pool.count, 7)
        
        // get connection while max connections count
        while connections.count < pool.maxConnections {
            let con = try pool.getConnection()
            connections.append(con)
        }
        
        XCTAssertEqual(connections.count, pool.maxConnections)
        XCTAssertEqual(pool.pool.count, pool.maxConnections)
        XCTAssertEqual(pool.inUseConnections, pool.maxConnections)
        
        // this connection getting failure
        pool.timeoutForGetConnection = 2
        XCTAssertThrowsError(try pool.getConnection())
        
        for c in connections {
            // release connections that we have got
            c.release()
        }
        connections.removeAll()
        XCTAssertEqual(pool.inUseConnections, 0)
        XCTAssertEqual(pool.pool.count, pool.maxConnections)
    }
    
    
    func testExecutionBlock() throws {
        
        var thisConn: Connection!
        try pool.execute { conn in
            thisConn = conn
            XCTAssertEqual(conn.isInUse, true)
            _ = try conn.query("SELECT 1 + 2;")
        }
        XCTAssertEqual(thisConn.isInUse, false)
    }

    private var errors: [Error?] = []
    private var errorSemaphore = DispatchSemaphore(value: 0)
    
    func testThreadingConnectionPool() throws {
        
        pool.maxConnections = 3
        pool.initialConnections = 3
        
        if #available(OSX 10.12, *) {
            
            let THREAD_COUNT = 10
            errors = [Error?](repeating: nil, count: THREAD_COUNT)
            let semaphore = DispatchSemaphore(value: 0)
            
            
            for i in 0..<THREAD_COUNT {
                Thread.detachNewThread {
                    print(Thread.current)
                    do {
                        try self.pool.execute { conn in
                            _ = try conn.query("SELECT 1 + 2;")
                            sleep(1)
                        }
                        print("done", Thread.current)
                    } catch {
                        print("error while executing", error)
                        self.errors[i] = error
                    }
                    
                    semaphore.signal()
                }
            }
            
            print("waiting until thread is done.")
            
            for _ in 0..<THREAD_COUNT {
                semaphore.wait()
            }
            
            print("thread done", errors)
            
            for i in 0..<THREAD_COUNT {
                if let error = errors[i] {
                    XCTFail("\(error)")
                }
            }
            
        } else {
            fatalError()
        }
    }
    
}
