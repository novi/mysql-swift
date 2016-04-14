//
//  SQLFormatterTests.swift
//  SQLFormatterTests
//
//  Created by Yusuke Ito on 4/5/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import SQLFormatter

extension SQLFormatterTests {
    static var allTests : [(String, SQLFormatterTests -> () throws -> Void)] {
        return [
                   ("testDummy", testDummy)
        ]
    }
}

class SQLFormatterTests: XCTestCase {
    
    func testDummy() throws {
        XCTAssertTrue(true)
    }
    
}
