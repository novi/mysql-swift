//
//  EscapeTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL
import SQLFormatter


extension EscapeTests {
    static var allTests : [(String, (EscapeTests) -> () throws -> Void)] {
        return [
                   ("testStringEscape", testStringEscape),
                   ("testBasicTypes", testBasicTypes),
                   ("testArrayType", testArrayType),
                   ("testNestedArray", testNestedArray),
                   ("testDictionary", testDictionary),
                   ("testAutoincrement", testAutoincrement)
        ]
    }
}

final class EscapeTests: XCTestCase {

    // https://github.com/felixge/node-mysql/blob/master/test/unit/protocol/test-SqlString.js
    func testStringEscape() {
        XCTAssertEqual(SQLString.escape(string: "Sup'er"), "'Sup\\'er'")
        
        XCTAssertEqual(SQLString.escape(string: "\u{00A5}"), "'¥'")
        XCTAssertEqual(SQLString.escape(string: "\\"), "'\\\\'")
        
        // escape combined character
        XCTAssertEqual(SQLString.escape(string: "'ﾞ"), "'\\'ﾞ'")
    }
    
    func testBasicTypes() throws {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        
        XCTAssertEqual(try QueryParameterOptional(strVal).queryParameter(option: queryOption).escaped(), "'Sup\\'er'")
        XCTAssertEqual(try QueryParameterOptional(strValOptional).queryParameter(option: queryOption).escaped(), "'Sup\\'er Super'")
        XCTAssertEqual(try QueryParameterOptional(strValOptionalNone).queryParameter(option: queryOption).escaped(), "NULL")
    }
    
    func testArrayType() throws {
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        let strs: [QueryParameter] = [strVal, strVal]
        
        XCTAssertEqual(try QueryParameterArray(strs).queryParameter(option: queryOption).escaped(), "'Sup\\'er', 'Sup\\'er'")
        
        let strsOptional1: [QueryParameter?] = [strVal, strValOptional]
        XCTAssertEqual(try QueryParameterArray(strsOptional1).queryParameter(option: queryOption).escaped(), "'Sup\\'er', 'Sup\\'er Super'")
        
        let strsOptional2: [QueryParameter?] = [strVal, strValOptionalNone]
        XCTAssertEqual(try QueryParameterArray(strsOptional2).queryParameter(option: queryOption).escaped(), "'Sup\\'er', NULL")
        
        
        let arr = QueryParameterArray(strs)
        let arrayOfArr = QueryParameterArray( [arr] )
        XCTAssertEqual(try arrayOfArr.queryParameter(option: queryOption).escaped(), "('Sup\\'er', 'Sup\\'er')")
        
        let strInt:[QueryParameter] = [strVal, 271]
        XCTAssertEqual(try QueryParameterArray(strInt).queryParameter(option: queryOption).escaped(), "'Sup\\'er', 271")
        
        let strOptionalAndInt:[QueryParameter] = [strValOptional, 3.14]
        XCTAssertEqual(try QueryParameterArray(strOptionalAndInt).queryParameter(option: queryOption).escaped(), "'Sup\\'er Super', 3.14")
    }
    
    func testNestedArray() throws {
        
        let strVal: String = "Sup'er"
        let strValOptionalNone: String? = nil
        let child: [QueryParameter] = [strVal, strValOptionalNone]
        let strs: [QueryParameter] = [strVal, strValOptionalNone, QueryParameterArray(child)]
        
        XCTAssertEqual(try QueryParameterArray(strs).queryParameter(option: queryOption).escaped(), "\'Sup\\\'er\', NULL, (\'Sup\\\'er\', NULL)")
        
    }
    
    func testAutoincrement() throws {
        let strVal: String = "Sup'er"
        
        do {
            let userID: AutoincrementID<UserID> = .ID(UserID(333))
            XCTAssertEqual(try userID.queryParameter(option: queryOption).escaped(), "333")
            let arr: [QueryParameter] = [strVal, userID]
            XCTAssertEqual(try QueryParameterArray(arr).queryParameter(option: queryOption).escaped(), "\'Sup\\\'er\', 333")
        }
        
        do {
            let stringID: AutoincrementID<SomeStringID> = .ID(SomeStringID("id-555@"))
            XCTAssertEqual(try stringID.queryParameter(option: queryOption).escaped(), "\'id-555@\'")
            let arr: [QueryParameter] = [strVal, stringID]
            XCTAssertEqual(try QueryParameterArray(arr).queryParameter(option: queryOption).escaped(), "\'Sup\\\'er\', \'id-555@\'")
        }
        
        do {
            let noID: AutoincrementID<UserID> = .noID
            XCTAssertEqual(try noID.queryParameter(option: queryOption).escaped(), "\'\'")
            
            let arr: [QueryParameter] = [strVal, noID]
            XCTAssertEqual(try QueryParameterArray(arr).queryParameter(option: queryOption).escaped(), "\'Sup\\\'er\'")
        }
    }
    
    func testDictionary() {
        
        
        let strVal: String = "Sup'er"
        let strValOptional: String? = "Sup'er Super"
        let strValOptionalNone: String? = nil
        
        let dict = QueryParameterDictionary([
            "string": strVal,
            "stringOptional": strValOptional,
            "stringNone" : strValOptionalNone
            ])
        
        let expectedResult = Set(arrayLiteral: "`string` = 'Sup\\'er'", "`stringOptional` = 'Sup\\'er Super'", "`stringNone` = NULL")
        let escaped = try! dict.queryParameter(option: queryOption).escaped()
        XCTAssertEqual(Set(escaped.split(separator: ",").map(String.init).map({ $0.trimmingCharacters(in: .whitespaces) })), expectedResult)
        
    }
    
}
