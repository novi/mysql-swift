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
            ("testCodableIDType_AutoincrementNoID", testCodableIDType_AutoincrementNoID)
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
        
        
        let expectedResult = Set(arrayLiteral: "`id` = 123", "`name` = 'test4456'", "`userType` = 'user'")
        
        do {
            let parameter: QueryParameter = CodableModel(id: UserID(123),
                                                         name: "test4456",
                                                         userType: .user)
            
            let result = try parameter.queryParameter(option: queryOption).escaped()
            
            XCTAssertEqual(Set(result.split(separator: ",").map(String.init).map({ $0.trimmingCharacters(in: .whitespaces) })), expectedResult)
        }
        
        do {
            let parameter: QueryParameter = CodableModelWithAutoincrement(id: AutoincrementID(UserID(123)),
                                                         name: "test4456",
                                                         userType: .user)
            
            let result = try parameter.queryParameter(option: queryOption).escaped()
            XCTAssertEqual(Set(result.split(separator: ",").map(String.init).map({ $0.trimmingCharacters(in: .whitespaces) })), expectedResult)
        }
        
    }
    
    func testCodableIDType_AutoincrementNoID() throws {
        
        
        let expectedResult = Set(arrayLiteral: "`name` = 'test4456'", "`userType` = 'user'")
        
        let parameter: QueryParameter = CodableModelWithAutoincrement(id: .noID,
                                                                      name: "test4456",
                                                                      userType: .user)
        
        let result = try parameter.queryParameter(option: queryOption).escaped()
        
        XCTAssertEqual(Set(result.split(separator: ",").map(String.init).map({ $0.trimmingCharacters(in: .whitespaces) })), expectedResult)
        
    }
    
}
