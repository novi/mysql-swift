//
//  SQLTypeTests.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
@testable import MySQL

extension SQLTypeTests {
    static var allTests : [(String, SQLTypeTests -> () throws -> Void)] {
        return [
                   ("testIDType", testIDType),
                    ("testEnumType", testEnumType)
        ]
    }
}

class SQLTypeTests: XCTestCase {
    
    
    struct SomeID: IDType {
        let id: Int
        init(_ id: Int) {
            self.id = id
        }
    }
    
    enum SomeEnum: String, SQLEnumType {
        case first = "first 1"
        case second = "second' 2"
    }

    func testIDType() throws {
        
        let someID: QueryParameter = SomeID(1234)
        XCTAssertEqual(try someID.queryParameter(option: queryOption).escaped(), "1234")
        
        let id: SomeID? = SomeID.from(string: "5678")
        XCTAssertEqual(id!.id, 5678)
    }
    
    func testEnumType() throws {
        
        let someVal: QueryParameter = SomeEnum.second
        let escaped = "second' 2".escaped()
        XCTAssertEqual(try someVal.queryParameter(option: queryOption).escaped() , escaped)
        
        let validVal: SomeEnum? = SomeEnum.from(string: "first 1")
        
        XCTAssertEqual(validVal!, SomeEnum.first)
        
        let nilVal: SomeEnum? = SomeEnum.from(string: "other foo")
        XCTAssertNil(nilVal)
    }

}
