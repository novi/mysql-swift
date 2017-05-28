//
//  DateTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
import CoreFoundation
import Foundation
@testable import MySQL

extension DateTests {
    static var allTests : [(String, (DateTests) -> () throws -> Void)] {
        return [
                   ("testSQLDate", testSQLDate),
                   ("testSQLCalendar", testSQLCalendar)
        ]
    }
}

extension XCTestCase {
    var queryOption: QueryParameterOption {
        return QueryParameterOption(timeZone: TimeZone(abbreviation: "UTC")!)
    }
}

class DateTests : XCTestCase {
    
    func testSQLDate() throws {
        
        let gmt = QueryParameterOption(timeZone: TimeZone(abbreviation: "UTC")!)
        let losAngeles = QueryParameterOption(timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        
        let expected = "2003-01-02 03:04:05" // no timezone
        
        let date = Date(timeIntervalSince1970: 1041476645) // "2003-01-02 03:04:05" at GMT
        XCTAssertEqual(date.queryParameter(option: gmt).escaped(), "'\(expected)'")
        
        let sqlDate = try Date(sqlDate: expected, timeZone: losAngeles.timeZone)
        let dateAtLos = Date(timeIntervalSince1970: 1041476645 + 3600*8)
    
        XCTAssertEqual(sqlDate, dateAtLos, "create date from sql string")
        XCTAssertEqual(sqlDate.queryParameter(option: losAngeles).escaped(), "'\(expected)'")
        
        XCTAssertEqual(sqlDate, dateAtLos)
        
        XCTAssertNotEqual(try Date(sqlDate: expected, timeZone: losAngeles.timeZone),
            try Date(sqlDate: expected, timeZone: gmt.timeZone))
        
        XCTAssertEqual(try Date(sqlDate: expected, timeZone: losAngeles.timeZone),
            try Date(sqlDate: expected, timeZone: losAngeles.timeZone))
        
        
        let sqlYear = try Date(sqlDate: "2021", timeZone: gmt.timeZone)
        XCTAssertEqual(sqlYear.queryParameter(option: gmt).escaped(), "'2021-01-01 00:00:00'")
    }
    
    func testSQLCalendar() {
        let gmt = TimeZone(abbreviation: "PDT")!
        let cal1 = SQLDateCalendar.calendar(forTimezone: gmt)
        let cal2 = SQLDateCalendar.calendar(forTimezone: gmt)
        //Unmanaged.passUnretained(cal1).toOpaque()
        //XCTAssertTrue(unsafeAddress(of: cal1 as AnyObject) == unsafeAddress(of: cal2 as AnyObject))
        XCTAssertEqual(cal1, cal2)
        XCTAssertEqual(cal1.hashValue, cal2.hashValue)
    }
    
}
