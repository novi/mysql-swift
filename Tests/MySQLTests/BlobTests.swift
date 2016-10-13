//
//  SQLTypeTests.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
import MySQL

extension BlobQueryTests {
    static var allTests : [(String, (BlobQueryTests) -> () throws -> Void)] {
        return [
                   ("testInsertForCombinedUnicodeCharacter", testInsertForCombinedUnicodeCharacter),
                    ("testBlobAndTextOnBinCollation", testBlobAndTextOnBinCollation),
                    ("testEscapeBlob", testEscapeBlob)
        ]
    }
}


class BlobQueryTests: XCTestCase, QueryTestType {
    
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
        try! createBlobTable()
    }
    
    func testInsertForCombinedUnicodeCharacter() throws {
        let str = "'ﾞ and áäèëî , ¥"
        
        let obj = Row.BlobTextRow(id: 0, text1: str, binary1: SQLBinary() )
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, obj])
        }
        XCTAssertEqual(status.insertedId, 1)
        
    }
    
    let testBinary: [UInt8] = [0, 0x1, 0x9, 0x10, 0x1f, 0x99, 0xff, 0x00, 0x0a]
    
    func testBlobAndTextOnBinCollation() throws {
        
        try createBinaryBlobTable()
        
        
        let obj = Row.BlobTextRow(id: 0, text1: "", binary1: SQLBinary(testBinary) )
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, obj])
        }
        XCTAssertEqual(status.insertedId, 1)
        
        let rows: [Row.BlobTextRow] = try pool.execute{ conn in
            try conn.query("SELECT * FROM ??", [constants.tableName])
        }
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].binary1.data.count, 9)
        XCTAssertEqual(rows[0].binary1.data, unsafeBitCast(testBinary, to: [Int8].self))
        print(rows[0].binary1.data, testBinary)
    }
    
    func testEscapeBlob() throws {
        
        
        let str = try SQLBinary(testBinary).queryParameter(option: queryOption).escaped()
        XCTAssertEqual(str, "x'000109101f99ff000a'")
        
    }
    
}
