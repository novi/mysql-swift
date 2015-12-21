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
        let formatted = try! QueryFormatter.format("SELECT name,??,id FROM users WHERE ?? = ? OR name = ? OR age is ?;", args: buildParam(params))
        XCTAssertEqual(formatted, "SELECT name,`i`.`d`,id FROM users WHERE `id` = 1 OR name = 'user\\'s' OR age is NULL;")
    }
    
}
