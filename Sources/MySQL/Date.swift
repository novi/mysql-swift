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

internal final class SQLDateCalender {
    private static let mutex = Mutex()

    private static var cals: [Connection.TimeZone:NSCalendar] = [:]

    internal static func calendar(forTimezone timeZone: Connection.TimeZone) -> NSCalendar {
        if let cal = cals[timeZone] {
            return cal
        }
        let newCal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        newCal.timeZone = unsafeBitCast(timeZone.timeZone, to: NSTimeZone.self) // TODO: in Linux
        self.save(calendar: newCal, forTimeZone: timeZone)
        return newCal
    }

    private static func save(calendar cal: NSCalendar, forTimeZone timeZone: Connection.TimeZone) {
        cals[timeZone] = cal
    }
}

public struct SQLDate {

    internal let timeInterval: NSTimeInterval?
    internal let sqlDate: String?

    public init(_ date: NSDate) {
        self.timeInterval = date.timeIntervalSince1970
        self.sqlDate = nil
    }

    public init(_ timeIntervalSince1970: NSTimeInterval) {
        self.timeInterval = timeIntervalSince1970
        self.sqlDate = nil
    }

    internal init() {
        self.init(NSDate())
    }

    internal init(sqlDate: String, timeZone: Connection.TimeZone) throws {

        SQLDateCalender.mutex.lock()

        defer {
            SQLDateCalender.mutex.unlock()
        }
        self.sqlDate = sqlDate
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
                let cal = SQLDateCalender.calendar(forTimezone: timeZone)
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
                    let cal = SQLDateCalender.calendar(forTimezone: timeZone)
                    if let date = cal.date(from :comp) {
                        self.timeInterval = date.timeIntervalSince1970
                        return
                    }
            }
        default: break
        }
        self.timeInterval = nil
        // throw QueryError.invalidSQLDate(sqlDate)
    }
    
    private func pad(num: Int32, digits: Int = 2) -> String {
        return pad(num: Int(num), digits: digits)
    }
    private func pad(num: Int8, digits: Int = 2) -> String {
        return pad(num: Int(num), digits: digits)
    }

    private func pad(num: Int, digits: Int = 2) -> String {
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
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        let compOptional = SQLDateCalender.mutex.sync { () -> NSDateComponents? in
            let cal = SQLDateCalender.calendar(forTimezone: option.timeZone)
            guard let date = date() else {
                return nil
            }
            return cal.components([ .year, .month,  .day,  .hour, .minute, .second], from: date)
            } // TODO: in Linux
        guard let comp = compOptional else {
            return "0000-00-00 00:00:00"
        }
        // YYYY-MM-DD HH:MM:SS
        return QueryParameterWrap( "'\(pad(num: comp.year, digits: 4))-\(pad(num: comp.month))-\(pad(num: comp.day)) \(pad(num: comp.hour)):\(pad(num: comp.minute)):\(pad(num: comp.second))'" )
    }
}

extension SQLDate : CustomStringConvertible {
    public var description: String {
        guard let date = date() else {
            guard let sqlDate = self.sqlDate else {
                return ""
            }
            return sqlDate
        }
        return date.description
    }
}

extension SQLDate {
    public static func now() -> SQLDate {
        return SQLDate()
    }
    public func date() -> NSDate? {
        guard let timeInterval = self.timeInterval else {
            return nil
        }
        return NSDate(timeIntervalSince1970: timeInterval)
    }
}

extension SQLDate: Equatable {

}

public func ==(lhs: SQLDate, rhs: SQLDate) -> Bool {
    return lhs.timeInterval == rhs.timeInterval
}

extension NSDate: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return SQLDate(self).queryParameter(option: option)
    }
}
