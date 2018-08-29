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
                   ("testSQLCalendar", testSQLCalendar),
                   ("testDateComponents", testDateComponents),
        ]
    }
}

struct QueryParameterTestOption: QueryParameterOption {
    let timeZone: TimeZone
}

extension XCTestCase {
    var queryOption: QueryParameterOption {
        return QueryParameterTestOption(timeZone: TimeZone(abbreviation: "UTC")!)
    }
}

final class DateTests : XCTestCase {
    
    func testSQLDate() throws {
        
        let gmt = QueryParameterTestOption(timeZone: TimeZone(abbreviation: "UTC")!)
        let losAngeles = QueryParameterTestOption(timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        
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
    }
    
    func testSQLCalendar() {
        let timeZone = TimeZone(abbreviation: "PDT")!
        let cal1 = SQLDateCalendar.calendar(forTimezone: timeZone, { $0 })
        let cal2 = SQLDateCalendar.calendar(forTimezone: timeZone, { $0 })
        XCTAssertEqual(cal1, cal2)
        XCTAssertEqual(cal1.hashValue, cal2.hashValue)
    }
    
    func testDateComponents() throws {
        
        do {
            // YEAR
            let comps = try DateComponents.fromSQLValue(string: "9999")
            XCTAssertEqual(comps.year, 9999)
        }
        
        do {
            // DATETIME
            // with nanoseconds
            let comps = try DateComponents.fromSQLValue(string: "9999-12-31 23:59:58.123456")
            XCTAssertEqual(comps.year, 9999)
            XCTAssertEqual(comps.month, 12)
            XCTAssertEqual(comps.day, 31)
            
            XCTAssertEqual(comps.hour, 23)
            XCTAssertEqual(comps.minute, 59)
            XCTAssertEqual(comps.second, 58)
            
            XCTAssertEqual(comps.nanosecond, 123456_000)
        }
        
        do {
            // DATETIME
            let comps = try DateComponents.fromSQLValue(string: "9999-12-31 23:59:58")
            XCTAssertEqual(comps.year, 9999)
            XCTAssertEqual(comps.month, 12)
            XCTAssertEqual(comps.day, 31)
            
            XCTAssertEqual(comps.hour, 23)
            XCTAssertEqual(comps.minute, 59)
            XCTAssertEqual(comps.second, 58)
        }
        
        do {
            // TIME
            // negative hours
            let comps = try DateComponents.fromSQLValue(string: "-123:59:58")
            
            XCTAssertEqual(comps.hour, -123)
            XCTAssertEqual(comps.minute, 59)
            XCTAssertEqual(comps.second, 58)
        }
        
        do {
            // TIME
            // with nanoseconds
            let comps = try DateComponents.fromSQLValue(string: "893:59:58.123456")
            XCTAssertEqual(comps.hour, 893)
            XCTAssertEqual(comps.minute, 59)
            XCTAssertEqual(comps.second, 58)
            
            XCTAssertEqual(comps.nanosecond, 123456_000)
        }
        
        do {
            // DATE
            let comps = try DateComponents.fromSQLValue(string: "9999-12-31")
            XCTAssertEqual(comps.year, 9999)
            XCTAssertEqual(comps.month, 12)
            XCTAssertEqual(comps.day, 31)
        }
        
    }
}
