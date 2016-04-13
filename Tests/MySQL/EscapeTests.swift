//
//  EscapeTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL
@testable import SQLFormatter

class EscapeTests: XCTestCase {
    
    // https://github.com/felixge/node-mysql/blob/master/test/unit/protocol/test-SqlString.js
    func testStringEscape() {
        XCTAssertEqual(SQLString.escape("Sup'er"), "'Sup\\'er'")
        
        
        // TODO
        
        XCTAssertEqual(SQLString.escape("\u{00A5}"), "'¥'")
        XCTAssertEqual(SQLString.escape("\\"), "'\\\\'")
        
        // escape combined character
        XCTAssertEqual(SQLString.escape("'ﾞ"), "'\\'ﾞ'")
    }
    
    func testBasicTypes() throws {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        
        XCTAssertEqual(try QueryOptional(strVal).queryParameter(option: queryOption).escapedValue(), "'Sup\\'er'")
        XCTAssertEqual(try QueryOptional(strValOptional).queryParameter(option: queryOption).escapedValue(), "'Sup\\'er Super'")
        XCTAssertEqual(try QueryOptional(strValOptionalNone).queryParameter(option: queryOption).escapedValue(), "NULL")
    }
    
    func testArrayType() throws {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        let strs: [QueryParameter] = [strVal, strVal]
        
        XCTAssertEqual(try QueryArray(strs).queryParameter(option: queryOption).escapedValue(), "'Sup\\'er', 'Sup\\'er'")
        
        let strsOptional1: [QueryParameter?] = [strVal, strValOptional]
        XCTAssertEqual(try QueryArray(strsOptional1).queryParameter(option: queryOption).escapedValue(), "'Sup\\'er', 'Sup\\'er Super'")
        
        let strsOptional2: [QueryParameter?] = [strVal, strValOptionalNone]
        XCTAssertEqual(try QueryArray(strsOptional2).queryParameter(option: queryOption).escapedValue(), "'Sup\\'er', NULL")
        
        
        let arr = QueryArray(strs)
        let arrayOfArr = QueryArray( [arr] )
        XCTAssertEqual(try arrayOfArr.queryParameter(option: queryOption).escapedValue(), "('Sup\\'er', 'Sup\\'er')")
        
        let strInt:[QueryParameter] = [strVal, 271]
        XCTAssertEqual(try QueryArray(strInt).queryParameter(option: queryOption).escapedValue(), "'Sup\\'er', 271")
        
        let strOptionalAndInt:[QueryParameter] = [strValOptional, 3.14]
        XCTAssertEqual(try QueryArray(strOptionalAndInt).queryParameter(option: queryOption).escapedValue(), "'Sup\\'er Super', 3.14")
    }
    
    func testNestedArray() throws {
        
        let strVal: String = "Sup'er"
        let strValOptionalNone: String? = nil
        let child: [QueryParameter] = [strVal, strValOptionalNone]
        let strs: [QueryParameter] = [strVal, strValOptionalNone, QueryArray(child)]
        
        XCTAssertEqual(try QueryArray(strs).queryParameter(option: queryOption).escapedValue(), "\'Sup\\\'er\', NULL, (\'Sup\\\'er\', NULL)")
        
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