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


final class QueryFormatterTests: XCTestCase {
    
    fileprivate enum TableName: String, QueryRawRepresentableParameter {
        case user = "user"
    }
    
    func testBasicFormatting() throws {
        
        let params: (String, TableName, String, Int, String, Int?) = (
            "i.d",
            TableName.user,
            "id",
            1,
            "user's",
            nil
        )
        let args: [QueryParameter] = [
            params.0,
            params.1,
            params.2,
            params.3,
            params.4,
            params.5,
        ]
        
        let formatted = try QueryFormatter.format(query: "SELECT name,??,id FROM ?? WHERE ?? = ? OR name = ? OR age is ?;", parameters: Connection.buildParameters(args, option: queryOption) )
        XCTAssertEqual(formatted, "SELECT name,`i`.`d`,id FROM `user` WHERE `id` = 1 OR name = 'user\\'s' OR age is NULL;")
    }
    
    func testPlaceholder() throws {
        let params: [QueryParameter] = ["name", "message??", "col", "hello??", "hello?"]
        let formatted = try QueryFormatter.format(query: "SELECT ??, ?, ??, ?, ?", parameters: Connection.buildParameters(params, option: queryOption))
        XCTAssertEqual(formatted, "SELECT `name`, 'message??', `col`, 'hello??', 'hello?'")
    }
    
    func testStringUtil() {
        let someString = "abcdefghijklmn12345"
        XCTAssertEqual(someString.subString(max: 10), "abcdefghij")
        XCTAssertEqual(someString.subString(max: 1000), someString)
        
        XCTAssertEqual("".subString(max: 10), "")
    }
}
