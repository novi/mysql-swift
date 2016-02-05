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
        
        let strs: [QueryParameter] = [strVal, strVal]
        
        XCTAssertEqual(try! QueryArray(strs).escapedValue(), "'Sup\\'er', 'Sup\\'er'")
        
        let strsOptional1: [QueryParameter?] = [strVal, strValOptional]
        XCTAssertEqual(try! QueryArray(strsOptional1).escapedValue(), "'Sup\\'er', 'Sup\\'er Super'")
        
        let strsOptional2: [QueryParameter?] = [strVal, strValOptionalNone]
        XCTAssertEqual(try! QueryArray(strsOptional2).escapedValue(), "'Sup\\'er', NULL")
        
        
        let arr = QueryArray(strs)
        let arrayOfArr = QueryArray( [arr] )
        XCTAssertEqual(try! arrayOfArr.escapedValue(), "('Sup\\'er', 'Sup\\'er')")
        
        let strInt:[QueryParameter] = [strVal, 271]
        XCTAssertEqual(try! QueryArray(strInt).escapedValue(), "'Sup\\'er', 271")
        
        let strOptionalAndInt:[QueryParameter] = [strValOptional, 3.14]
        XCTAssertEqual(try! QueryArray(strOptionalAndInt).escapedValue(), "'Sup\\'er Super', 3.14")
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