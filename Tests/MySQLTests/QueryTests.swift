//
//  QueryTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL
import Foundation

extension QueryTests {
    static var allTests : [(String, (QueryTests) -> () throws -> Void)] {
        return [
            ("testInsertRowCodable", testInsertRowCodable),
            ("testEmojiInserting", testEmojiInserting),
            ("testBulkInsert", testBulkInsert)
        ]
    }
}

extension QueryURLTypeTests {
    static var allTests : [(String, (QueryURLTypeTests) -> () throws -> Void)] {
        return [
            ("testURLType", testURLType),
            ("testURLInvalid", testURLInvalid)
        ]
    }
}


protocol QueryTestType: MySQLTestType {
    func dropTestTable() throws
}

extension QueryTestType {
    func dropTestTable() throws {
        let conn = try pool.getConnection()
        _ = try conn.query("DROP TABLE IF EXISTS \(constants.tableName)")
    }
}


final class QueryTests: XCTestCase, QueryTestType {
    
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
        try! createTestTable()
    }
    
    func createTestTable() throws {
        try dropTestTable()
        
        let conn = try pool.getConnection()
        let query = "CREATE TABLE `\(constants.tableName)` (" +
            "`id` int(11) unsigned NOT NULL AUTO_INCREMENT," +
            "`name` varchar(50) NOT NULL DEFAULT ''," +
            "`age` int(11) NOT NULL," +
            "`created_at` datetime NOT NULL DEFAULT '2001-01-01 00:00:00'," +
            "`name_Optional` varchar(50) DEFAULT NULL," +
            "`age_Optional` int(11) DEFAULT NULL," +
            "`created_at_Optional` datetime DEFAULT NULL," +
            "`done` tinyint(1) NOT NULL DEFAULT 0," +
            "`done_Optional` tinyint(1) DEFAULT NULL," +
            "`user_type` varchar(50) NOT NULL DEFAULT ''," +
            "PRIMARY KEY (`id`)" +
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
        
        _ = try conn.query(query)
    }
    
    private var someDate: Date {
        return try! Date(sqlDate: "2015-12-27 16:54:00", timeZone: pool.options.timeZone)
    }
    
    private var anotherDate: Date {
        return Date(timeIntervalSinceReferenceDate: 60*60*24*67)
    }
    
    func testInsertRowCodable() throws {
        
        typealias User = Row.User
        
        let name = "name 's"
        let age = 25
        
        let userNil = User(id: .noID, name: name, age: age, createdAt: someDate, nameOptional: nil, ageOptional: nil, createdAtOptional: nil, done: false, doneOptional: nil, userType: .user)
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, userNil])
        }
        XCTAssertEqual(status.insertedID, 1)
        
        let userFill = User(id: .ID(UserID(134)), name: name, age: age, createdAt: someDate,  nameOptional: "fuga", ageOptional: 50, createdAtOptional: anotherDate, done: true, doneOptional: false, userType: .admin)
        let status2: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, userFill])
        }
        XCTAssertEqual(status2.insertedID, 134)
        
        let rows:[User] = try pool.execute { conn in
            try conn.query("SELECT id,name,age,created_at,name_Optional,age_Optional,created_at_Optional,done,done_Optional,user_type FROM ??", [constants.tableName])
        }
        
        XCTAssertEqual(rows.count, 2)
        
        // first row
        XCTAssertEqual(rows[0].id.id, UserID(1))
        XCTAssertEqual(rows[0].name, name)
        XCTAssertEqual(rows[0].age, age)
        XCTAssertEqual(rows[0].createdAt, someDate)
        
        XCTAssertNil(rows[0].nameOptional)
        XCTAssertNil(rows[0].ageOptional)
        XCTAssertNil(rows[0].createdAtOptional)
        
        XCTAssertFalse(rows[0].done)
        XCTAssertNil(rows[0].doneOptional)
        
        XCTAssertEqual(rows[0].userType, .user)
        
        // second row
        XCTAssertEqual(rows[1].id.id, UserID(134))
        XCTAssertEqual(rows[1].name, name)
        XCTAssertEqual(rows[1].age, age)
        XCTAssertEqual(rows[1].createdAt, someDate)
        
        XCTAssertNotNil(rows[1].nameOptional)
        XCTAssertNotNil(rows[1].ageOptional)
        XCTAssertNotNil(rows[1].createdAtOptional)
        
        XCTAssertEqual(rows[1].nameOptional, "fuga")
        XCTAssertEqual(rows[1].ageOptional, 50)
        XCTAssertEqual(rows[1].createdAtOptional, anotherDate)
        
        XCTAssertTrue(rows[1].done)
        XCTAssertFalse(rows[1].doneOptional!)
        
        XCTAssertEqual(rows[1].userType, .admin)
    }
    
    
    func testEmojiInserting() throws {
        
        typealias User = Row.User
        
        
        let now = Date()
        let user = User(id: .noID, name: "日本語123🍣🍺あいう", age: 123, createdAt: now, nameOptional: nil, ageOptional: nil, createdAtOptional: nil, done: false, doneOptional: nil, userType: .user)
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, user])
        }
        
        let rows: [User] = try pool.execute{ conn in
            try conn.query("SELECT id,name,age,created_at,name_Optional,age_Optional,created_at_Optional,done,done_Optional,user_type FROM ?? WHERE id = ?", [constants.tableName, status.insertedID])
        }
        XCTAssertEqual(rows.count, 1)
        let fetched = rows[0]
        XCTAssertEqual(fetched.name, "日本語123🍣🍺あいう")
        XCTAssertEqual(fetched.age, 123)
    }
    
    
    func testBulkInsert() throws {
        
        //let now = Date()
        let users = (1...3).map({ row in
            Row.SimpleUser(id: UInt(10+row), name: "name\(row)", age: row)
        })
    
        let usersParam: [QueryParameterArray] = users.map { user in
            QueryParameterArray([user.id, user.name, user.age])
        }
        
        _ = try pool.execute { conn in
            try conn.query("INSERT INTO ??(id,name,age) VALUES ? ", [constants.tableName, QueryParameterArray(usersParam)])
        }
        
        let selectedUsersCodeable: [Row.SimpleUser] = try pool.execute { conn in
            try conn.query("SELECT id,name,age FROM ?? ORDER BY id DESC", [constants.tableName])
        }
        XCTAssertEqual(selectedUsersCodeable.count, 3)
        
        for (index, row) in (1...3).reversed().enumerated() {
            XCTAssertEqual(selectedUsersCodeable[index].id, UInt(10+row))
            XCTAssertEqual(selectedUsersCodeable[index].name, "name\(row)")
            XCTAssertEqual(selectedUsersCodeable[index].age, row)
        }
    }
    
}


final class QueryURLTypeTests: XCTestCase, QueryTestType {
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
        try! createURLTestTable()
    }

    func createURLTestTable() throws {
        try dropTestTable()
        
        let conn = try pool.getConnection()
        let query = """
        CREATE TABLE `\(constants.tableName)` (
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `url` mediumtext NOT NULL,
        `url_Optional` mediumtext,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        _ = try conn.query(query)
    }
    
    
    
    func testURLType() throws {
        
        let urlRow1 = Row.URLRow(url: URL(string: "https://apple.com/iphone")!, urlOptional: nil)
        let urlRow2 = Row.URLRow(url: URL(string: "https://apple.com/iphone")!, urlOptional: URL(string: "https://apple.com/ipad")!)
        
        try pool.execute { conn in
            _ = try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, urlRow1])
            _ = try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, urlRow2])
        }
        
        let rows: [Row.URLRow] = try pool.execute {
            try $0.query("SELECT * FROM ?? ORDER BY id ASC", [constants.tableName])
        }
        
        XCTAssertEqual(rows[0], urlRow1)
        XCTAssertEqual(rows[1], urlRow2)
    }
    
    func testURLInvalid() throws {
        
        try pool.execute { conn in
            _ = try conn.query("INSERT INTO ?? SET `url` = ''", [constants.tableName])
        }
        
        do {
            let _: [Row.URLRow] = try pool.execute {
                try $0.query("SELECT * FROM ?? ORDER BY id ASC", [constants.tableName])
            }
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                print(context)
                // expected error
            default:
                XCTFail("unexpected error \(error)")
            }
        } catch {
            XCTFail("unexpected error \(error)")
        }
    }
    
}

