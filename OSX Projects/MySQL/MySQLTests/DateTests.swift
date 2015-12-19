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
        let timeZone = CFTimeZoneCreateWithName(nil, "America/Los_Angeles", true)
        
        let expected = "2003-01-02 03:04:05" // no timezone
        
        let date = SQLDate(absoluteTime: 63169445, timeZone: gmt) // "2003-01-02 03:04:05" at GMT
        XCTAssertEqual(date.escapedValue(), "'\(expected)'")
        
        let sqlDate = try! SQLDate(sqlDate: expected, timeZone: timeZone)
        let dateAtLos = SQLDate(absoluteTime: 63169445 + 60*60*8, timeZone: timeZone)
        
        XCTAssertEqual(sqlDate.absoluteTime, dateAtLos.absoluteTime, "create date from sql string")
        XCTAssertEqual(sqlDate.escapedValue(), "'\(expected)'")
        
        XCTAssertEqual(sqlDate, dateAtLos)
        
        XCTAssertNotEqual(try! SQLDate(sqlDate: expected, timeZone: timeZone),
            try! SQLDate(sqlDate: expected, timeZone: gmt))
        
        XCTAssertEqual(try! SQLDate(sqlDate: expected, timeZone: timeZone),
            try! SQLDate(sqlDate: expected, timeZone: timeZone))
        
        
        let sqlYear = try! SQLDate(sqlDate: "2021", timeZone: gmt)
        XCTAssertEqual(sqlYear.escapedValue(), "'2021-01-01 00:00:00'")
    }
    
}