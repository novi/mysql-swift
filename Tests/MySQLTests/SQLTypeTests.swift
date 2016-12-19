//
//  SQLTypeTests.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
import MySQL

extension SQLTypeTests {
    static var allTests : [(String, (SQLTypeTests) -> () throws -> Void)] {
        return [
                   ("testIDType", testIDType),
                    ("testEnumType", testEnumType),
                    ("testAutoincrementType", testAutoincrementType)
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
        
        let id: SomeID = try SomeID.fromSQL(string: "5678")
        XCTAssertEqual(id.id, 5678)
    }
    
    func testEnumType() throws {
        
        let someVal: QueryParameter = SomeEnum.second
        let escaped = "second' 2".escaped()
        XCTAssertEqual(try someVal.queryParameter(option: queryOption).escaped() , escaped)
        
        let validVal: SomeEnum = try SomeEnum.fromSQL(string: "first 1")
        
        XCTAssertEqual(validVal, SomeEnum.first)
        
        XCTAssertThrowsError(try SomeEnum.fromSQL(string: "other foo"))
    }
    
    func testAutoincrementType() throws {
        
        let userID: AutoincrementID<UserID> = .ID(UserID(333))
        XCTAssertEqual(userID, AutoincrementID.ID(UserID(333)))
        
        let someStringID: AutoincrementID<SomeStringID> = .ID(SomeStringID("id678@"))
        XCTAssertEqual(someStringID, AutoincrementID.ID(SomeStringID("id678@")))
        
        let noID: AutoincrementID<UserID> = .noID
        XCTAssertEqual(noID, AutoincrementID.noID)
    }

}
