//
//  EscapeTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

class EscapeTests: XCTestCase, XCTestCaseProvider {
    
    var allTests: [(String, () throws -> Void)] {
        return self.dynamicType.allTests.map{ ($0.0, $0.1(self)) }
    }
    
    // https://github.com/felixge/node-mysql/blob/master/test/unit/protocol/test-SqlString.js
    func testStringEscape() {
        XCTAssertEqual(SQLString.escape("Sup'er"), "'Sup\\'er'")
        
        
        // TODO
        
        XCTAssertEqual(SQLString.escape("\u{00A5}"), "'¥'")
        XCTAssertEqual(SQLString.escape("\\"), "'\\\\'")
        
        // escape combined character
        XCTAssertEqual(SQLString.escape("'ﾞ"), "'\\'ﾞ'")
    }
    
    func testBasicTypes() {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        
        XCTAssertEqual(try! QueryOptional<String>(strVal).escapedValueWith(option: queryOption), "'Sup\\'er'")
        XCTAssertEqual(try! QueryOptional<String>(strValOptional).escapedValueWith(option: queryOption), "'Sup\\'er Super'")
        XCTAssertEqual(try! QueryOptional<String>(strValOptionalNone).escapedValueWith(option: queryOption), "NULL")
    }
    
    func testArrayType() {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        let strs: [QueryParameter] = [strVal, strVal]
        
        XCTAssertEqual(try! QueryArray(strs).escapedValueWith(option: queryOption), "'Sup\\'er', 'Sup\\'er'")
        
        let strsOptional1: [QueryParameter?] = [strVal, strValOptional]
        XCTAssertEqual(try! QueryArray(strsOptional1).escapedValueWith(option: queryOption), "'Sup\\'er', 'Sup\\'er Super'")
        
        let strsOptional2: [QueryParameter?] = [strVal, strValOptionalNone]
        XCTAssertEqual(try! QueryArray(strsOptional2).escapedValueWith(option: queryOption), "'Sup\\'er', NULL")
        
        
        let arr = QueryArray(strs)
        let arrayOfArr = QueryArray( [arr] )
        XCTAssertEqual(try! arrayOfArr.escapedValueWith(option: queryOption), "('Sup\\'er', 'Sup\\'er')")
        
        let strInt:[QueryParameter] = [strVal, 271]
        XCTAssertEqual(try! QueryArray(strInt).escapedValueWith(option: queryOption), "'Sup\\'er', 271")
        
        let strOptionalAndInt:[QueryParameter] = [strValOptional, 3.14]
        XCTAssertEqual(try! QueryArray(strOptionalAndInt).escapedValueWith(option: queryOption), "'Sup\\'er Super', 3.14")
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