//
//  QueryFormatterTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

class QueryFormatterTests: XCTestCase {
    
    func testBasicFormatting() {
        
        let params: (String, String, Int, String, Int?) = (
            "i.d",
            "id",
            1,
            "user's",
            nil
        )
        let formatted = try! QueryFormatter.format("SELECT name,??,id FROM users WHERE ?? = ? OR name = ? OR age is ?;", args: build(params), option: queryOption)
        XCTAssertEqual(formatted, "SELECT name,`i`.`d`,id FROM users WHERE `id` = 1 OR name = 'user\\'s' OR age is NULL;")
    }
    
    func testPlaceholder() {
        let formatted = try! QueryFormatter.format("SELECT ??, ?, ??, ?, ?", args: ["name", "message??", "col", "hello??", "hello?"], option: queryOption)
        XCTAssertEqual(formatted, "SELECT `name`, 'message??', `col`, 'hello??', 'hello?'")
    }
    
    func testStringUtil() {
        let someString = "abcdefghijklmn12345"
        XCTAssertEqual(someString.subString(max: 10), "abcdefghij")
        XCTAssertEqual(someString.subString(max: 1000), someString)
        
        XCTAssertEqual("".subString(max: 10), "")
    }
}
