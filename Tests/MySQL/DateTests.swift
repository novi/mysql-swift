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
    static var allTests : [(String, DateTests -> () throws -> Void)] {
        return [
                   ("testSQLDate", testSQLDate),
                   ("testSQLCalendar", testSQLCalendar)
        ]
    }
}

extension XCTestCase {
    var queryOption: QueryParameterOption {
        return QueryParameterOption(timeZone: Connection.TimeZone(GMTOffset: 0))
    }
}

class DateTests : XCTestCase {
    
    func testSQLDate() throws {
        
        let gmt = QueryParameterOption(timeZone: Connection.TimeZone(GMTOffset: 0))
        let losAngeles = QueryParameterOption(timeZone: Connection.TimeZone(name: "America/Los_Angeles"))
        
        let expected = "2003-01-02 03:04:05" // no timezone
        
        let date = SQLDate(NSDate(timeIntervalSince1970: 1041476645)) // "2003-01-02 03:04:05" at GMT
        XCTAssertEqual(date.queryParameter(option: gmt).escaped(), "'\(expected)'")
        
        let sqlDate = try SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone)
        let dateAtLos = SQLDate(NSDate(timeIntervalSince1970: 1041476645 + 3600*8))
        
        XCTAssertEqual(sqlDate.timeInterval, dateAtLos.timeInterval, "create date from sql string")
        XCTAssertEqual(sqlDate.queryParameter(option: losAngeles).escaped(), "'\(expected)'")
        
        XCTAssertEqual(sqlDate, dateAtLos)
        
        XCTAssertNotEqual(try SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone),
            try SQLDate(sqlDate: expected, timeZone: gmt.timeZone))
        
        XCTAssertEqual(try SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone),
            try SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone))
        
        
        let sqlYear = try SQLDate(sqlDate: "2021", timeZone: gmt.timeZone)
        XCTAssertEqual(sqlYear.queryParameter(option: gmt).escaped(), "'2021-01-01 00:00:00'")
    }
    
    func testSQLCalendar() {
        let gmt = Connection.TimeZone(GMTOffset: 100)
        let cal1 = SQLDateCalender.calendar(forTimezone: gmt)
        let cal2 = SQLDateCalender.calendar(forTimezone: gmt)
        XCTAssertTrue(unsafeAddress(of: cal1) == unsafeAddress(of: cal2))
        XCTAssertEqual(cal1, cal2)
        XCTAssertEqual(cal1.hashValue, cal2.hashValue)
    }
    
}