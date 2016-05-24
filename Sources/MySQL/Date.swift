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

    public enum DateType {
        case date
        case dateTime
        case time
        case year
    }

    internal let timeInterval: NSTimeInterval?
    internal let sqlDate: String?
    internal let dateType: DateType

    public init(_ date: NSDate, dateType:DateType = .dateTime) {
        self.timeInterval = date.timeIntervalSince1970
        self.sqlDate = nil
        self.dateType = dateType
    }

    public init(_ timeIntervalSince1970: NSTimeInterval, dateType:DateType = .dateTime) {
        self.timeInterval = timeIntervalSince1970
        self.sqlDate = nil
        self.dateType = dateType
    }

    internal init(dateType:DateType = .dateTime) {
        self.init(NSDate(),dateType: dateType)
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
                    self.dateType = .year
                    self.timeInterval = date.timeIntervalSince1970
                    return
                }
            }
        case 8:
            let chars:[Character] = Array(sqlDate.characters)
            if  let hour = Int(String(chars[0...1])),
                let minute = Int(String(chars[3...4])),
                let second = Int(String(chars[6...7])) {
                let year = 2000
                let month = 1
                let day = 1
                let comp = NSDateComponents()
                comp.year = year
                comp.month = month
                comp.day = day
                comp.hour = hour
                comp.minute = minute
                comp.second = second
                let cal = SQLDateCalender.calendar(forTimezone: timeZone)
                if let date = cal.date(from :comp) {
                    self.dateType = .time
                    self.timeInterval = date.timeIntervalSince1970
                    return
                }
            }
        case 10:
            let chars:[Character] = Array(sqlDate.characters)
            self.dateType = .date
            if let year = Int(String(chars[0...3])),
                let month = Int(String(chars[5...6])),
                let day = Int(String(chars[8...9]))
                where year > 0 && day > 0 && month > 0 {
                let hour = 0
                let minute = 0
                let second = 0
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
            } else {
                self.timeInterval = nil
                return
            }
        case 19:
            let chars:[Character] = Array(sqlDate.characters)
            self.dateType = .dateTime
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
            } else {
                self.timeInterval = nil
                return
            }
        default: break
        }
        throw QueryError.invalidSQLDate(sqlDate)
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
            switch self.dateType {
            case .date:
                return "0000-00-00"
            case .time:
                return "00:00:00"
            case .year:
                return "0000"
            case .dateTime:
                return "0000-00-00 00:00:00"
            }
        }
        switch self.dateType {
        case .date:
            return QueryParameterWrap( "'\(pad(num: comp.year, digits: 4))-\(pad(num: comp.month))-\(pad(num: comp.day))'" )
        case .time:
            return QueryParameterWrap( "'\(pad(num: comp.hour)):\(pad(num: comp.minute)):\(pad(num: comp.second))'" )
        case .year:
            return QueryParameterWrap( "'\(pad(num: comp.year, digits: 4))'" )
        case .dateTime:
            return QueryParameterWrap( "'\(pad(num: comp.year, digits: 4))-\(pad(num: comp.month))-\(pad(num: comp.day)) \(pad(num: comp.hour)):\(pad(num: comp.minute)):\(pad(num: comp.second))'" )
        }
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
    public static func now(dateType:DateType = .dateTime) -> SQLDate {
        return SQLDate(dateType:dateType)
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
