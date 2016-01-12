//
//  DateTests.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import XCTest
import CoreFoundation
@testable import MySQL

class DateTests : XCTestCase {
    
    func testSQLDate() {
        
        let gmt = CFTimeZoneCreateWithTimeIntervalFromGMT(nil, 0)
        let losAngeles = CFTimeZoneCreateWithName(nil, "America/Los_Angeles", true)
        
        let expected = "2003-01-02 03:04:05" // no timezone
        
        let date = SQLDate(date: NSDate(timeIntervalSince1970: 1041476645), timeZone: gmt) // "2003-01-02 03:04:05" at GMT
        XCTAssertEqual(date.escapedValue(), "'\(expected)'")
        
        let sqlDate = try! SQLDate(sqlDate: expected, timeZone: losAngeles)
        let dateAtLos = SQLDate(date: NSDate(timeIntervalSince1970: 1041476645 + 3600*8), timeZone: losAngeles)
        
        XCTAssertEqual(sqlDate.date, dateAtLos.date, "create date from sql string")
        XCTAssertEqual(sqlDate.escapedValue(), "'\(expected)'")
        
        XCTAssertEqual(sqlDate, dateAtLos)
        
        XCTAssertNotEqual(try! SQLDate(sqlDate: expected, timeZone: losAngeles),
            try! SQLDate(sqlDate: expected, timeZone: gmt))
        
        XCTAssertEqual(try! SQLDate(sqlDate: expected, timeZone: losAngeles),
            try! SQLDate(sqlDate: expected, timeZone: losAngeles))
        
        
        let sqlYear = try! SQLDate(sqlDate: "2021", timeZone: gmt)
        XCTAssertEqual(sqlYear.escapedValue(), "'2021-01-01 00:00:00'")
    }
    
}