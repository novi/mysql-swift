//
//  SQLFormatterTests.swift
//  SQLFormatterTests
//
//  Created by Yusuke Ito on 4/5/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import SQLFormatter

extension SQLFormattingTests {
    static var allTests : [(String, (SQLFormattingTests) -> () throws -> Void)] {
        return [
                   ("testDummy", testDummy)
        ]
    }
}

class SQLFormattingTests: XCTestCase {
    
    func testDummy() throws {
        XCTAssertTrue(true)
    }
}

#if !os(macOS)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase( SQLFormattingTests.allTests ),
        ]
    }
#endif
