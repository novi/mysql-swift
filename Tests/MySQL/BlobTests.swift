//
//  SQLTypeTests.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

extension BlobQueryTests {
    static var allTests : [(String, BlobQueryTests -> () throws -> Void)] {
        return [
                   ("testInsertForCombinedUnicodeCharacter", testInsertForCombinedUnicodeCharacter)
        ]
    }
}


class BlobQueryTests: XCTestCase, QueryTestType {
    
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
        try! createTextBlobTable()
    }
    
    func testInsertForCombinedUnicodeCharacter() throws {
        let str = "'ﾞ and áäèëî , ¥"
        
        let obj = Row.BlobTextRow(id: 0, text1: str)
        let status: QueryStatus = try pool.execute { conn in
            try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, obj])
        }
        XCTAssertEqual(status.insertedId, 1)
        
    }
    
}
