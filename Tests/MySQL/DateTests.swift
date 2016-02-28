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

extension XCTestCase {
    var queryOption: QueryParameterOption {
        return QueryParameterOption(timeZone: Connection.TimeZone(GMTOffset: 0))
    }
}

class DateTests : XCTestCase {
    
    func testSQLDate() {
        
        let gmt = QueryParameterOption(timeZone: Connection.TimeZone(GMTOffset: 0))
        let losAngeles = QueryParameterOption(timeZone: Connection.TimeZone(name: "America/Los_Angeles"))
        
        let expected = "2003-01-02 03:04:05" // no timezone
        
        let date = SQLDate(NSDate(timeIntervalSince1970: 1041476645)) // "2003-01-02 03:04:05" at GMT
        XCTAssertEqual(date.escapedValueWith(option: gmt), "'\(expected)'")
        
        let sqlDate = try! SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone)
        let dateAtLos = SQLDate(NSDate(timeIntervalSince1970: 1041476645 + 3600*8))
        
        XCTAssertEqual(sqlDate.timeInterval, dateAtLos.timeInterval, "create date from sql string")
        XCTAssertEqual(sqlDate.escapedValueWith(option: losAngeles), "'\(expected)'")
        
        XCTAssertEqual(sqlDate, dateAtLos)
        
        XCTAssertNotEqual(try! SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone),
            try! SQLDate(sqlDate: expected, timeZone: gmt.timeZone))
        
        XCTAssertEqual(try! SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone),
            try! SQLDate(sqlDate: expected, timeZone: losAngeles.timeZone))
        
        
        let sqlYear = try! SQLDate(sqlDate: "2021", timeZone: gmt.timeZone)
        XCTAssertEqual(sqlYear.escapedValueWith(option: gmt), "'2021-01-01 00:00:00'")
    }
    
    func testSQLCalendar() {
        let gmt = Connection.TimeZone(GMTOffset: 100)
        let cal1 = SQLDateCalender.calendarFor(gmt)
        let cal2 = SQLDateCalender.calendarFor(gmt)
        XCTAssertTrue(unsafeAddressOf(cal1) == unsafeAddressOf(cal2))
        XCTAssertEqual(cal1, cal2)
        XCTAssertEqual(cal1.hashValue, cal2.hashValue)
    }
    
}