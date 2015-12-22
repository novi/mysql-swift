//
//  QueryTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

class QueryTestBase: MySQLTests {
    
    func createTestTable() throws {
        try dropTestTable()
        
        let conn = createConnection()
        let query = "CREATE TABLE `\(constants.tableName)` (" +
        "`id` int(11) unsigned NOT NULL AUTO_INCREMENT," +
        "`name` varchar(50) NOT NULL DEFAULT ''," +
        "`age` int(11) NOT NULL," +
        "`created_at` datetime NOT NULL DEFAULT '2001-01-01 00:00:00'," +
        "`name_Optional` varchar(50) DEFAULT NULL," +
        "`age_Optional` int(11) DEFAULT NULL," +
        "`created_at_Optional` datetime DEFAULT NULL," +
        "PRIMARY KEY (`id`)" +
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8;"
        
        try conn.query(query)
    }
    
    func dropTestTable() throws {
        let conn = createConnection()
        try conn.query("DROP TABLE IF EXISTS \(constants.tableName)")
    }
}

class QueryTests: QueryTestBase {
    
    var now: SQLDate!
    var connection: Connection!
    
    override func setUp() {
        super.setUp()
        self.connection = createConnection()
        if now == nil {
            self.now = SQLDate.now(timeZone: connection.options.timeZone)
        }
    }
    
    func testCreateAndDrop() {
        try! createTestTable()
    }
    
    var anotherDate: SQLDate {
        return SQLDate(absoluteTime: 60*60*24*67, timeZone: connection.options.timeZone.timeZone)
    }
    
    func testInsertRow() {
        typealias User = Row.UserDecodeWithIndex
        
        let name = "name 's"
        let age = 25
        
        let userNil = User(id: 0, name: name, age: age, createdAt: now, nameOptional: nil, ageOptional: nil, createdAtOptional: nil)
        let status: QueryStatus = try! connection.query("INSERT INTO \(constants.tableName) SET ? ", [userNil])
        XCTAssertEqual(status.insertedId, 1)
        
        let userFill = User(id: 0, name: name, age: age, createdAt: now, nameOptional: "fuga", ageOptional: 50, createdAtOptional: anotherDate)
        let status2: QueryStatus = try! connection.query("INSERT INTO \(constants.tableName) SET ? ", [userFill])
        XCTAssertEqual(status2.insertedId, 2)
        
        let rows:[User] = try! connection.query("SELECT id,name,age,created_at,name_Optional,age_Optional,created_at_Optional FROM \(constants.tableName)")
        
        XCTAssertEqual(rows.count, 2)
        
        // first row
        XCTAssertEqual(rows[0].id, 1)
        XCTAssertEqual(rows[0].name, name)
        XCTAssertEqual(rows[0].age, age)
        XCTAssertEqual(rows[0].createdAt, now)
        
        XCTAssertNil(rows[0].nameOptional)
        XCTAssertNil(rows[0].ageOptional)
        XCTAssertNil(rows[0].createdAtOptional)
        
        // second row
        XCTAssertEqual(rows[1].id, 2)
        XCTAssertEqual(rows[1].name, name)
        XCTAssertEqual(rows[1].age, age)
        XCTAssertEqual(rows[1].createdAt, now)
        
        XCTAssertNotNil(rows[1].nameOptional)
        XCTAssertNotNil(rows[1].ageOptional)
        XCTAssertNotNil(rows[1].createdAtOptional)
        
        XCTAssertEqual(rows[1].nameOptional, "fuga")
        XCTAssertEqual(rows[1].ageOptional, 50)
        XCTAssertEqual(rows[1].createdAtOptional, anotherDate)
    }
    
    func testSelectingWithFieldKey() {
        
        let name = "name 's"
        let age = 25
        
        typealias User = Row.UserDecodeWithKey
        let rows:[User] = try! connection.query("SELECT * FROM \(constants.tableName) LIMIT ?", [2])
        
        XCTAssertEqual(rows.count, 2)
        
        // first row
        XCTAssertEqual(rows[0].id, 1)
        XCTAssertEqual(rows[0].name, name)
        XCTAssertEqual(rows[0].age, age)
        XCTAssertEqual(rows[0].createdAt, now)
        
        XCTAssertNil(rows[0].nameOptional)
        XCTAssertNil(rows[0].ageOptional)
        XCTAssertNil(rows[0].createdAtOptional)
        
        // second row
        XCTAssertEqual(rows[1].id, 2)
        XCTAssertEqual(rows[1].name, name)
        XCTAssertEqual(rows[1].age, age)
        XCTAssertEqual(rows[1].createdAt, now)
        
        XCTAssertNotNil(rows[1].nameOptional)
        XCTAssertNotNil(rows[1].ageOptional)
        XCTAssertNotNil(rows[1].createdAtOptional)
        
        XCTAssertEqual(rows[1].nameOptional, "fuga")
        XCTAssertEqual(rows[1].ageOptional, 50)
        XCTAssertEqual(rows[1].createdAtOptional, anotherDate)
    }
    
    
}
