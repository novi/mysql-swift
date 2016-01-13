//
//  Date.swift
//  MySQL
//
//  Created by ito on 12/16/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import CoreFoundation
import Foundation

final class SQLDateCalender {
    static let mutex = Mutex()
    
    static var cals: [Connection.TimeZone:NSCalendar] = [:]
    
    static func calendarFor(timeZone: Connection.TimeZone) -> NSCalendar {
        if let cal = cals[timeZone] {
            return cal
        }
        let newCal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        newCal.timeZone = unsafeBitCast(timeZone.timeZone, NSTimeZone.self) // TODO: in Linux
        self.saveCalendar(newCal, forTimeZone: timeZone)
        return newCal
    }
    
    static func saveCalendar(cal: NSCalendar, forTimeZone timeZone: Connection.TimeZone) {
        cals[timeZone] = cal
    }
}

public struct SQLDate {
    let date: NSTimeInterval
    let timeZone: Connection.TimeZone
    
    init(date: NSDate, timeZone: Connection.TimeZone) {
        self.date = date.timeIntervalSince1970
        self.timeZone = timeZone
    }
    
    init(sqlDate: String, timeZone: Connection.TimeZone) throws {
        self.timeZone = timeZone
        
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
                if let date = cal.dateFromComponents(comp) {
                    self.date = date.timeIntervalSince1970
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
                    if let date = cal.dateFromComponents(comp) {
                        self.date = date.timeIntervalSince1970
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
    public func escapedValue() -> String {
        let comp = SQLDateCalender.mutex.sync { () -> NSDateComponents? in
            let cal = SQLDateCalender.calendarFor(timeZone)
            return cal.components([ .Year, .Month,  .Day,  .Hour, .Minute, .Second], fromDate: NSDate(timeIntervalSince1970: date))
        }! // TODO: in Linux
        
        // YYYY-MM-DD HH:MM:SS
        return "'\(padNum(comp.year, digits: 4))-\(padNum(comp.month))-\(padNum(comp.day)) \(padNum(comp.hour)):\(padNum(comp.minute)):\(padNum(comp.second))'"
    }
}

extension SQLDate : CustomStringConvertible {
    public var description: String {
        return NSDate(timeIntervalSince1970: date).description + "/" + "\(CFTimeZoneGetName(timeZone.timeZone))"
    }
}

extension SQLDate {
    public static func now(timeZone timeZone: Connection.TimeZone) -> SQLDate {
        return SQLDate(date: NSDate(), timeZone: timeZone)
    }
}

extension SQLDate: Equatable {
    
}

public func ==(lhs: SQLDate, rhs: SQLDate) -> Bool {
    return lhs.date == rhs.date
}

