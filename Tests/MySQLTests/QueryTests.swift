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

protocol QueryTestType: MySQLTestType {
    func dropTestTable() throws
}

extension QueryTestType {
    func dropTestTable() throws {
        let conn = try pool.getConnection()
        _ = try conn.query("DROP TABLE IF EXISTS \(constants.tableName)")
    }
}

extension Row {
    
    fileprivate struct SimpleUser: Codable, Equatable {
        let id: UInt
        let name: String
        let age: Int
    }
    
    fileprivate enum UserType: String, Codable {
        case user = "user"
        case admin = "admin"
    }
    
    fileprivate struct User: Codable, QueryParameter, Equatable {
        let id: AutoincrementID<UserID>
        
        let name: String
        let age: Int
        let createdAt: Date
        
        let createdAtDateComponentsOptional: DateComponents?
        
        let nameOptional: String?
        let ageOptional: Int?
        let createdAtOptional: Date?
        
        let done: Bool
        let doneOptional: Bool?
        
        let userType: UserType
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case age
            case createdAt = "created_at"
            
            case createdAtDateComponentsOptional = "created_at_datecomponents_Optional"
            case nameOptional = "name_Optional"
            case ageOptional = "age_Optional"
            case createdAtOptional = "created_at_Optional"
            case done
            case doneOptional = "done_Optional"
            case userType = "user_type"
        }
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
        let query = """
            CREATE TABLE `\(constants.tableName)` (
            `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
            `name` varchar(50) NOT NULL DEFAULT '',
            `age` int(11) NOT NULL,
            `created_at` datetime NOT NULL DEFAULT '2001-01-01 00:00:00',
            `created_at_datecomponents_Optional` datetime(6) DEFAULT NULL,
            `name_Optional` varchar(50) DEFAULT NULL,
            `age_Optional` int(11) DEFAULT NULL,
            `created_at_Optional` datetime DEFAULT NULL,
            `done` tinyint(1) NOT NULL DEFAULT 0,
            `done_Optional` tinyint(1) DEFAULT NULL,
            `user_type` varchar(255) NOT NULL DEFAULT '',
            PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            """
        
        _ = try conn.query(query)
    }
    
    private var someDate: Date {
        return try! Date(sqlDate: "2015-12-27 16:54:00", timeZone: pool.option.timeZone)
    }
    
    private var anotherDate: Date {
        return Date(timeIntervalSinceReferenceDate: 60*60*24*67)
    }
    
    func testInsertRowCodable() throws {
        
        typealias User = Row.User
        
        let name = "name 's"
        let age = 25
        
        let dateComponents = DateComponents(year: 2012, month: 3, day: 4, hour: 5, minute: 6, second: 7, nanosecond: 890_000_000)
        
        let userNil = User(id: .noID, name: name, age: age, createdAt: someDate, createdAtDateComponentsOptional: dateComponents, nameOptional: nil, ageOptional: nil, createdAtOptional: nil, done: false, doneOptional: nil, userType: .user)
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, userNil])
        }
        XCTAssertEqual(status.insertedID, 1)
        
        let userFill = User(id: .ID(UserID(134)), name: name, age: age, createdAt: someDate, createdAtDateComponentsOptional: dateComponents, nameOptional: "fuga", ageOptional: 50, createdAtOptional: anotherDate, done: true, doneOptional: false, userType: .admin)
        let status2: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, userFill])
        }
        XCTAssertEqual(status2.insertedID, 134)
        
        let rows:[User] = try pool.execute { conn in
            try conn.query("SELECT id,name,age,created_at,created_at_datecomponents_Optional,name_Optional,age_Optional,created_at_Optional,done,done_Optional,user_type FROM ?? ORDER BY id ASC", [constants.tableName])
        }
        
        XCTAssertEqual(rows.count, 2)
        
        // first row
        XCTAssertEqual(rows[0].id.id, UserID(Int(status.insertedID)))
        XCTAssertEqual(rows[0].name, name)
        XCTAssertEqual(rows[0].age, age)
        XCTAssertEqual(rows[0].createdAt, someDate)
        
        XCTAssertNil(rows[0].nameOptional)
        XCTAssertNil(rows[0].ageOptional)
        XCTAssertNil(rows[0].createdAtOptional)
        
        XCTAssertFalse(rows[0].done)
        XCTAssertNil(rows[0].doneOptional)
        
        XCTAssertEqual(rows[0].userType, .user)
        
        XCTAssertEqual(rows[1], userFill)
    }
    
    func testTransaction() throws {
        
        let user = Row.User(id: .noID, name: "name", age: 11, createdAt: someDate, createdAtDateComponentsOptional: nil, nameOptional: nil, ageOptional: nil, createdAtOptional: nil, done: false, doneOptional: nil, userType: .user)
        let status: QueryStatus = try pool.transaction { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, user])
        }
        XCTAssertEqual(status.insertedID, 1)
    }
    
    
    func testEmojiInserting() throws {
        
        typealias User = Row.User
        
        
        let now = Date()
        let user = User(id: .noID, name: "日本語123🍣🍺あいう", age: 123, createdAt: now, createdAtDateComponentsOptional: nil, nameOptional: nil, ageOptional: nil, createdAtOptional: nil, done: false, doneOptional: nil, userType: .user)
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, user])
        }
        
        let rows: [User] = try pool.execute{ conn in
            try conn.query("SELECT id,name,age,created_at,name_Optional,age_Optional,created_at_Optional,done,done_Optional,user_type FROM ?? WHERE id = ?", [constants.tableName, status.insertedID])
        }
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].name, user.name)
        XCTAssertEqual(rows[0].age, user.age)
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
        
        let fetchedUsers: [Row.SimpleUser] = try pool.execute { conn in
            try conn.query("SELECT id,name,age FROM ?? ORDER BY id DESC", [constants.tableName])
        }
        XCTAssertEqual(fetchedUsers.count, 3)
        
        for index in (0..<3) {
            XCTAssertEqual(fetchedUsers[index], users.reversed()[index])
        }
    }
    
}

