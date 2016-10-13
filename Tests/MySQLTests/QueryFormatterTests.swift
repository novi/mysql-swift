//
//  QueryFormatterTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL
import SQLFormatter

extension QueryFormatterTests {
    static var allTests : [(String, (QueryFormatterTests) -> () throws -> Void)] {
        return [
                   ("testBasicFormatting", testBasicFormatting),
                   ("testPlaceholder", testPlaceholder),
                    ("testStringUtil", testStringUtil)
        ]
    }
}


class QueryFormatterTests: XCTestCase {
    
    func testBasicFormatting() throws {
        
        let params: (String, String, Int, String, Int?) = (
            "i.d",
            "id",
            1,
            "user's",
            nil
        )
        let args = build(params)
        
        let formatted = try QueryFormatter.format(query: "SELECT name,??,id FROM users WHERE ?? = ? OR name = ? OR age is ?;", args: Connection.buildArgs(args, option: queryOption) )
        XCTAssertEqual(formatted, "SELECT name,`i`.`d`,id FROM users WHERE `id` = 1 OR name = 'user\\'s' OR age is NULL;")
    }
    
    func testPlaceholder() throws {
        let params: [QueryParameter] = ["name", "message??", "col", "hello??", "hello?"]
        let formatted = try QueryFormatter.format(query: "SELECT ??, ?, ??, ?, ?", args: Connection.buildArgs(params, option: queryOption))
        XCTAssertEqual(formatted, "SELECT `name`, 'message??', `col`, 'hello??', 'hello?'")
    }
    
    func testStringUtil() {
        let someString = "abcdefghijklmn12345"
        XCTAssertEqual(someString.subString(max: 10), "abcdefghij")
        XCTAssertEqual(someString.subString(max: 1000), someString)
        
        XCTAssertEqual("".subString(max: 10), "")
    }
}
