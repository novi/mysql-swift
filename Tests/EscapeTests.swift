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
    func testStringEscape() {
        XCTAssertEqual(SQLString.escape("Sup'er"), "'Sup\\'er'")
        
        
        // TODO
        
    }
    
    func testBasicTypes() {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        
        XCTAssertEqual(try! QueryOptional<String>(strVal).escapedValue(), "'Sup\\'er'")
        XCTAssertEqual(try! QueryOptional<String>(strValOptional).escapedValue(), "'Sup\\'er Super'")
        XCTAssertEqual(try! QueryOptional<String>(strValOptionalNone).escapedValue(), "NULL")
    }
    
    func testArrayType() {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        let strs: [String] = [strVal, strVal]
        
        XCTAssertEqual(try! QueryArray<String>(strs).escapedValue(), "'Sup\\'er', 'Sup\\'er'")
        
        let strsOptional1: [String?] = [strVal, strValOptional]
        XCTAssertEqual(try! QueryArray<String>(strsOptional1).escapedValue(), "'Sup\\'er', 'Sup\\'er Super'")
        
        let strsOptional2: [String?] = [strVal, strValOptionalNone]
        XCTAssertEqual(try! QueryArray<String>(strsOptional2).escapedValue(), "'Sup\\'er', NULL")
        
        
        let arr = QueryArray<String>(strs)
        let arrayOfArr = QueryArray<QueryArray<String>>( [arr] )
        XCTAssertEqual(try! arrayOfArr.escapedValue(), "('Sup\\'er', 'Sup\\'er')")
    }
    
    func testDictionary() {
        
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        let dict = QueryDictionary([
            "string": strVal,
            "stringOptional": strValOptional,
            "stringNone" : strValOptionalNone
            ])
        
        // TODO:
        // "`string` = 'Sup\\'er', `stringOptional` = 'Sup\\'er Super', `stringNone` = NULL"
        // XCTAssertEqual(try! dict.escapedValue(), )
    }
    
}