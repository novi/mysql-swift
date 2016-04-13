//
//  Date.swift
//  MySQL
//
//  Created by ito on 12/16/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import CoreFoundation
import Foundation
import SQLFormatter

#if os(OSX)
#else
    extension NSCalendar {
        func date(from comps: NSDateComponents) -> NSDate? {
            return self.dateFromComponents(comps)
        }
        func components(unitFlags: NSCalendarUnit, from date: NSDate) -> NSDateComponents? {
            return self.components(unitFlags, fromDate: date)
        }
    }
    
    extension NSCalendarUnit {
        public static var year: NSCalendarUnit = NSCalendarUnit.Year
        
        public static var month: NSCalendarUnit = NSCalendarUnit.Month
        
        public static var day: NSCalendarUnit = NSCalendarUnit.Day
        
        public static var hour: NSCalendarUnit = NSCalendarUnit.Hour
        
        public static var minute: NSCalendarUnit = NSCalendarUnit.Minute
    
        public static var second: NSCalendarUnit = NSCalendarUnit.Second
    }
    
#endif

internal final class SQLDateCalender {
    private static let mutex = Mutex()
    
    private static var cals: [Connection.TimeZone:NSCalendar] = [:]
    
    internal static func calendarFor(timeZone: Connection.TimeZone) -> NSCalendar {
        if let cal = cals[timeZone] {
            return cal
        }
        let newCal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        newCal.timeZone = unsafeBitCast(timeZone.timeZone, to: NSTimeZone.self) // TODO: in Linux
        self.saveCalendar(newCal, forTimeZone: timeZone)
        return newCal
    }
    
    private static func saveCalendar(cal: NSCalendar, forTimeZone timeZone: Connection.TimeZone) {
        cals[timeZone] = cal
    }
}

public struct SQLDate {
    
    internal let timeInterval: NSTimeInterval
    
    public init(_ date: NSDate) {
        self.timeInterval = date.timeIntervalSince1970
    }
    
    public init(_ timeIntervalSince1970: NSTimeInterval) {
        self.timeInterval = timeIntervalSince1970
    }
    
    internal init() {
        self.init(NSDate())
    }
    
    internal init(sqlDate: String, timeZone: Connection.TimeZone) throws {
        
        SQLDateCalender.mutex.lock()
        
        defer {
            SQLDateCalender.mutex.unlock()
        }
        
        switch sqlDate.characters.count {
        case 4:
            if let year = Int(sqlDate) {
                let comp = NSDateComponents()
                comp.year = year
                comp.month = 1
                comp.day = 1
                comp.hour = 0
                comp.minute = 0
                comp.second = 0
                let cal = SQLDateCalender.calendarFor(timeZone)
                if let date = cal.date(from: comp) {
                    self.timeInterval = date.timeIntervalSince1970
                    return
                }
            }
        case 19:
            let chars:[Character] = Array(sqlDate.characters)
            if let year = Int(String(chars[0...3])),
                let month = Int(String(chars[5...6])),
                let day = Int(String(chars[8...9])),
                let hour = Int(String(chars[11...12])),
                let minute = Int(String(chars[14...15])),
                let second = Int(String(chars[17...18])) where year > 0 && day > 0 && month > 0 {
                    let comp = NSDateComponents()
                    comp.year = year
                    comp.month = month
                    comp.day = day
                    comp.hour = hour
                    comp.minute = minute
                    comp.second = second
                    let cal = SQLDateCalender.calendarFor(timeZone)
                    if let date = cal.date(from :comp) {
                        self.timeInterval = date.timeIntervalSince1970
                        return
                    }
            }
        default: break
        }
        
        throw QueryError.InvalidSQLDate(sqlDate)
    }
    
    func padNum(num: Int32, digits: Int = 2) -> String {
        return padNum(Int(num), digits: digits)
    }
    func padNum(num: Int8, digits: Int = 2) -> String {
        return padNum(Int(num), digits: digits)
    }
    
    func padNum(num: Int, digits: Int = 2) -> String {
        var str = String(num)
        if num < 0 {
            return str
        }
        while str.characters.count < digits {
            str = "0" + str
        }
        return str
    }
}

extension SQLDate: QueryParameter {
    public func queryParameter(option option: QueryParameterOption) throws -> QueryParameterType {
        let comp = SQLDateCalender.mutex.sync { () -> NSDateComponents? in
            let cal = SQLDateCalender.calendarFor(option.timeZone)
            return cal.components([ .year, .month,  .day,  .hour, .minute, .second], from: date())
            }! // TODO: in Linux
        
        // YYYY-MM-DD HH:MM:SS
        return QueryParameterWrap( "'\(padNum(comp.year, digits: 4))-\(padNum(comp.month))-\(padNum(comp.day)) \(padNum(comp.hour)):\(padNum(comp.minute)):\(padNum(comp.second))'" )
    }
}

extension SQLDate : CustomStringConvertible {
    public var description: String {
        return date().description
    }
}

extension SQLDate {
    public static func now() -> SQLDate {
        return SQLDate()
    }
    public func date() -> NSDate {
        return NSDate(timeIntervalSince1970: timeInterval)
    }
}

extension SQLDate: Equatable {
    
}

public func ==(lhs: SQLDate, rhs: SQLDate) -> Bool {
    return lhs.timeInterval == rhs.timeInterval
}

extension NSDate: QueryParameter {
    public func queryParameter(option option: QueryParameterOption) throws -> QueryParameterType {
        return try SQLDate(self).queryParameter(option: option)
    }
}

