//
//  SQLTypeTests.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL
import Foundation

extension BlobQueryTests {
    static var allTests : [(String, (BlobQueryTests) -> () throws -> Void)] {
        return [
                   ("testInsertForCombinedUnicodeCharacter", testInsertForCombinedUnicodeCharacter),
                   ("testBlobAndTextOnBinCollation", testBlobAndTextOnBinCollation),
                   ("testEscapeBlob", testEscapeBlob),
                   ("testJSONColumnValue", testJSONColumnValue)
        ]
    }
}


extension Row {
    
    fileprivate struct BlobTextRow: Codable, QueryParameter {
        let id: AutoincrementID<BlobTextID>
        
        let text1: String
        let binary1: Data
    }
    
    fileprivate struct JSONDataUser: Codable, Equatable, QueryCustomDataParameter, QueryRowResultCustomData {
        func encodeForQueryParameter() throws -> Data {
            let encoder = JSONEncoder()
            return try encoder.encode(self)
        }
        
        var queryParameterDataType: QueryCustomDataParameterDataType {
            return .json
        }
        
        static func decode(fromRowData data: Data) throws -> Row.JSONDataUser {
            let decoder = JSONDecoder()
            return try decoder.decode(self, from: data)
        }
        
        // this type decoded from and encoded to Data, like JSON, Protobuf...
        let name: String
    }
    
    fileprivate struct JSONColumnUser: Codable, QueryParameter, Equatable {
        let userName: String
        let jsonValue_blob: JSONDataUser
        let jsonValue_json: JSONDataUser
    }
    
}

final class BlobQueryTests: XCTestCase, QueryTestType {
    
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
        try! createBlobTable()
    }
    
    func createBinaryBlobTable() throws {
        try dropTestTable()
        
        let conn = try pool.getConnection()
        let query = "CREATE TABLE `\(constants.tableName)` (" +
            "`id` int(11) unsigned NOT NULL AUTO_INCREMENT," +
            "`text1` mediumtext NOT NULL," +
            "`binary1` mediumblob NOT NULL," +
            "PRIMARY KEY (`id`)" +
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;"
        
        _ = try conn.query(query)
    }
    
    func createBlobTable() throws {
        try dropTestTable()
        
        let conn = try pool.getConnection()
        let query = "CREATE TABLE `\(constants.tableName)` (" +
            "`id` int(11) unsigned NOT NULL AUTO_INCREMENT," +
            "`text1` mediumtext NOT NULL," +
            "`binary1` mediumblob NOT NULL," +
            "PRIMARY KEY (`id`)" +
        ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
        
        _ = try conn.query(query)
    }
    
    func testInsertForCombinedUnicodeCharacter() throws {
        let str = "'ﾞ and áäèëî , ¥"
        
        let obj = Row.BlobTextRow(id: .noID, text1: str, binary1: Data() )
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, obj])
        }
        XCTAssertEqual(status.insertedID, 1)
        
    }
    
    private let testBinary: [UInt8] = [0, 0x1, 0x9, 0x10, 0x1f, 0x99, 0xff, 0x00, 0x0a]
    
    func testBlobAndTextOnBinCollation() throws {
        
        try createBinaryBlobTable()
        
        
        let obj = Row.BlobTextRow(id: .noID, text1: "", binary1: Data(testBinary) )
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, obj])
        }
        XCTAssertEqual(status.insertedID, 1)
        
        let rows: [Row.BlobTextRow] = try pool.execute{ conn in
            try conn.query("SELECT * FROM ??", [constants.tableName])
        }
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].binary1.count, 9)
        XCTAssertEqual(rows[0].binary1, Data(testBinary))
        
        print(rows[0].binary1, testBinary)
    }
    
    func testEscapeBlob() throws {
        
        do {
            let str = try Data(testBinary).queryParameter(option: queryOption).escaped()
            XCTAssertEqual(str, "x'000109101f99ff000a'")
        }
    }
    
    
    private func createJSONValueTable() throws {
        try dropTestTable()
        
        let conn = try pool.getConnection()
        let query = """
        CREATE TABLE `\(constants.tableName)` (
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `userName` mediumtext NOT NULL,
        `jsonValue_blob` mediumblob NOT NULL,
        `jsonValue_json` json NOT NULL,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        _ = try conn.query(query)
    }
    
    func testJSONColumnValue() throws {
        
        try createJSONValueTable()
        
        let jsonValue = Row.JSONDataUser(name: "name in json value")
        let user = Row.JSONColumnUser(userName: "john", jsonValue_blob: jsonValue, jsonValue_json: jsonValue)
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, user])
        }
        XCTAssertEqual(status.insertedID, 1)
        
        let rows: [Row.JSONColumnUser] = try pool.execute{ conn in
            try conn.query("SELECT * FROM ??", [constants.tableName])
        }
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0], user)
    }
    
}
