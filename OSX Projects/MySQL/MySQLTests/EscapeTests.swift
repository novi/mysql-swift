//
//  EscapeTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

class EscapeTests: XCTestCase {
    
    // https://github.com/felixge/node-mysql/blob/master/test/unit/protocol/test-SqlString.js
    func testEscape() {
        XCTAssertEqual(SQLString.escape("Sup'er"), "'Sup\\'er'")
        
        
        // TODO
        
    }
    
}