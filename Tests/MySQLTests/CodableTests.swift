//
//  CodableTests.swift
//  MySQLTests
//
//  Created by Yusuke Ito on 1/22/18.
//

import XCTest
import MySQL

extension CodableTests {
    static var allTests : [(String, (CodableTests) -> () throws -> Void)] {
        return [
            ("testCodableIDType", testCodableIDType),
        ]
    }
}

final class CodableTests: XCTestCase {
    
    enum UserType: String, Codable {
        case user = "user"
        case admin = "admin"
    }
    
    struct CodableModel: Codable, QueryParameter {
        let id: UserID
        let name: String
        let userType: UserType
    }
    
    struct CodableModelWithAutoincrement: Codable, QueryParameter {
        let id: AutoincrementID<UserID>
        let name: String
        let userType: UserType
    }

    func testCodableIDType() throws {
        
        let parameter: QueryParameter = CodableModel(id: UserID(123),
                                                     name: "test4456",
                                                     userType: .user)
        
        XCTAssertEqual(try parameter.queryParameter(option: queryOption).escaped(),
                       "`id` = 123, `name` = 'test4456', `userType` = 'user'" )
        
    }
    
}
