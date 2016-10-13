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

internal final class SQLDateCalendar {
    fileprivate static let mutex = Mutex()
    
    private static var cals: [TimeZone:Calendar] = [:]
    
    internal static func calendar(forTimezone timeZone: TimeZone) -> Calendar {
        if let cal = cals[timeZone] {
            return cal
        }
        var newCal = Calendar(identifier: Calendar.Identifier.gregorian)
        newCal.timeZone = timeZone
        self.save(calendar: newCal, forTimeZone: timeZone)
        return newCal
    }
    
    private static func save(calendar cal: Calendar, forTimeZone timeZone: TimeZone) {
        cals[timeZone] = cal
    }
}

public struct SQLDate {
    
    internal let timeInterval: TimeInterval
    
    public init(_ date: Date) {
        self.timeInterval = date.timeIntervalSince1970
    }
    
    public init(_ timeIntervalSince1970: TimeInterval) {
        self.timeInterval = timeIntervalSince1970
    }
    
    internal init() {
        self.init(Date())
    }
    
    internal init(sqlDate: String, timeZone: TimeZone) throws {
        
        SQLDateCalendar.mutex.lock()
        
        defer {
            SQLDateCalendar.mutex.unlock()
        }
        
        switch sqlDate.characters.count {
        case 4:
            if let year = Int(sqlDate) {
                var comp = DateComponents()
                comp.year = year
                comp.month = 1
                comp.day = 1
                comp.hour = 0
                comp.minute = 0
                comp.second = 0
                let cal = SQLDateCalendar.calendar(forTimezone: timeZone)
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
                let second = Int(String(chars[17...18])), year > 0 && day > 0 && month > 0 {
                    var comp = DateComponents()
                    comp.year = year
                    comp.month = month
                    comp.day = day
                    comp.hour = hour
                    comp.minute = minute
                    comp.second = second
                    let cal = SQLDateCalendar.calendar(forTimezone: timeZone)
                    if let date = cal.date(from :comp) {
                        self.timeInterval = date.timeIntervalSince1970
                        return
                    }
            }
        default: break
        }
        
        throw QueryError.invalidSQLDate(sqlDate)
    }
    
    fileprivate func pad(num: Int32, digits: Int = 2) -> String {
        return pad(num: Int(num), digits: digits)
    }
    fileprivate func pad(num: Int8, digits: Int = 2) -> String {
        return pad(num: Int(num), digits: digits)
    }
    
    fileprivate func pad(num: Int, digits: Int = 2) -> String {
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
        let comp = SQLDateCalendar.mutex.sync { () -> DateComponents in
            let cal = SQLDateCalendar.calendar(forTimezone: option.timeZone)
            return cal.dateComponents([ .year, .month,  .day,  .hour, .minute, .second], from: date())
            } // TODO: in Linux
        
        // YYYY-MM-DD HH:MM:SS
        return QueryParameterWrap( "'\(pad(num: comp.year ?? 0, digits: 4))-\(pad(num: comp.month ?? 0))-\(pad(num: comp.day ?? 0)) \(pad(num: comp.hour ?? 0)):\(pad(num: comp.minute ?? 0)):\(pad(num: comp.second ?? 0))'" )
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
    public func date() -> Date {
        return Date(timeIntervalSince1970: timeInterval)
    }
}

extension SQLDate: Equatable {
    
}

public func ==(lhs: SQLDate, rhs: SQLDate) -> Bool {
    return lhs.timeInterval == rhs.timeInterval
}

extension Date: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return SQLDate(self).queryParameter(option: option)
    }
}

