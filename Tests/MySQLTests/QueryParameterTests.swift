//
//  QueryParameterTests.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest
import MySQL

extension QueryParameterTests {
    static var allTests : [(String, (QueryParameterTests) -> () throws -> Void)] {
        return [
                ("testIDType", testIDType),
                ("testIDTypeInContainer", testIDTypeInContainer),
                ("testEnumType", testEnumType),
                ("testAutoincrementType", testAutoincrementType),
                ("testDataAndURLType", testDataAndURLType),
                ("testDecimalType", testDecimalType),
                ("testCodableIDType", testCodableIDType),
                ("testCodableIDType_AutoincrementNoID", testCodableIDType_AutoincrementNoID)
        ]
    }
}

final class QueryParameterTests: XCTestCase {
    
    
    private struct IDInt: IDType {
        let id: Int
        init(_ id: Int) {
            self.id = id
        }
    }
    
    private struct IDString: IDType {
        let id: String
        init(_ id: String) {
            self.id = id
        }
    }
    
    private struct ModelWithIDType_StringAutoincrement: Encodable, QueryParameter {
        let idStringAutoincrement: AutoincrementID<IDString>
    }
    
    private struct ModelWithIDType_IntAutoincrement: Encodable, QueryParameter {
        let idIntAutoincrement: AutoincrementID<IDInt>
    }
    
    private enum SomeEnumParameter: String, QueryRawRepresentableParameter {
        case first = "first 1"
        case second = "second' 2"
    }
    
    private enum SomeEnumCodable: String, Codable, QueryParameter {
        case first = "first 1"
        case second = "second' 2"
    }
    
    // https://developer.apple.com/documentation/swift/optionset
    private struct ShippingOptions: OptionSet, QueryRawRepresentableParameter {
        let rawValue: Int
        
        static let nextDay    = ShippingOptions(rawValue: 1 << 0)
        static let secondDay  = ShippingOptions(rawValue: 1 << 1)
        static let priority   = ShippingOptions(rawValue: 1 << 2)
        static let standard   = ShippingOptions(rawValue: 1 << 3)
        
        static let express: ShippingOptions = [.nextDay, .secondDay]
        static let all: ShippingOptions = [.express, .priority, .standard]
    }
    
    private struct ModelWithData: Encodable, QueryParameter {
        let data: Data
    }
    
    private struct ModelWithDate: Encodable, QueryParameter {
        let date: Date
    }
    
    private struct ModelWithURL: Encodable, QueryParameter {
        let url: URL
    }
    
    private struct ModelWithDecimal: Encodable, QueryParameter {
        let value: Decimal
    }

    func testIDType() throws {
        
        let idInt: QueryParameter = IDInt(1234)
        XCTAssertEqual(try idInt.queryParameter(option: queryOption).escaped(), "1234")
        
        //let id: SomeID = try SomeID.fromSQLValue(string: "5678")
        //XCTAssertEqual(id.id, 5678)
        
        let idString: QueryParameter = IDString("123abc")
        XCTAssertEqual(try idString.queryParameter(option: queryOption).escaped(), "'123abc'")
        
        
        let idIntAutoincrement: QueryParameter = AutoincrementID(IDInt(1234))
        XCTAssertEqual(try idIntAutoincrement.queryParameter(option: queryOption).escaped(), "1234")
        
        let idStringAutoincrement: QueryParameter = AutoincrementID(IDString("123abc"))
        XCTAssertEqual(try idStringAutoincrement.queryParameter(option: queryOption).escaped(), "'123abc'")
        
    }
    
    func testIDTypeInContainer() throws {
        
        do {
            let param: QueryParameter = ModelWithIDType_IntAutoincrement(idIntAutoincrement: .ID(IDInt(1234)))
            XCTAssertEqual(try param.queryParameter(option: queryOption).escaped(), "`idIntAutoincrement` = 1234")
        }
        do {
            let param: QueryParameter = ModelWithIDType_StringAutoincrement(idStringAutoincrement: .ID(IDString("123abc")))
            XCTAssertEqual(try param.queryParameter(option: queryOption).escaped(), "`idStringAutoincrement` = '123abc'")
        }
        
    }
    
    func testEnumType() throws {
        
        do {
            let someVal: QueryParameter = SomeEnumParameter.second
            let escaped = "second' 2".escaped()
            XCTAssertEqual(try someVal.queryParameter(option: queryOption).escaped() , escaped)
        }
        
        do {
            let someVal: QueryParameter = SomeEnumCodable.second
            let escaped = "second' 2".escaped()
            XCTAssertEqual(try someVal.queryParameter(option: queryOption).escaped() , escaped)
        }
        
        do {
            let someOption: QueryParameter = ShippingOptions.all
            XCTAssertEqual(try someOption.queryParameter(option: queryOption).escaped() , "\(ShippingOptions.all.rawValue)")
        }
    }
    
    func testAutoincrementType() throws {
        
        let userID: AutoincrementID<UserID> = .ID(UserID(333))
        XCTAssertEqual(userID, AutoincrementID.ID(UserID(333)))
        
        let someStringID: AutoincrementID<SomeStringID> = .ID(SomeStringID("id678@"))
        XCTAssertEqual(someStringID, AutoincrementID.ID(SomeStringID("id678@")))
        
        let noID: AutoincrementID<UserID> = .noID
        XCTAssertEqual(noID, AutoincrementID.noID)
    }
    
    func testDataAndURLType() throws {
        
        do {
            let dataModel = ModelWithData(data: Data([0x12, 0x34, 0x56, 0xff, 0x00]))
            let queryString = try dataModel.queryParameter(option: queryOption).escaped()
            XCTAssertEqual(queryString,
                           "`data` = x'123456ff00'")
        }
        
        do {
            let urlModel = ModelWithURL(url: URL(string: "https://apple.com/iphone")!)
            let queryString = try urlModel.queryParameter(option: queryOption).escaped()
            XCTAssertEqual(queryString,
                           "`url` = 'https://apple.com/iphone'")
        }
    }

    func testDecimalType() throws {
        let decimalModel = ModelWithDecimal(value: Decimal(1.2345e100))
        let queryString = try decimalModel.queryParameter(option: queryOption).escaped()
        XCTAssertEqual(queryString,
                       "`value` = '12345000000000010240000000000000000000000000000000000000000000000000000000000000000000000000000000000'")
    }
    
    private enum UserType: String, Codable {
        case user = "user"
        case admin = "admin"
    }
    
    private struct CodableModel: Codable, QueryParameter {
        let id: UserID
        let name: String
        let userType: UserType
    }
    
    private struct CodableModelWithAutoincrement: Codable, QueryParameter {
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
