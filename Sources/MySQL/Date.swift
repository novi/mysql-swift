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


extension Date {
    
    internal init(sqlDate: String, timeZone: TimeZone) throws {
        
        SQLDateCalendar.mutex.lock()
        
        defer {
            SQLDateCalendar.mutex.unlock()
        }
        
        switch sqlDate.count {
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
                    self = date
                    return
                }
            }
        case 19:
            let chars: [Character] = Array(sqlDate)
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
                    self = date
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
        while str.count < digits {
            str = "0" + str
        }
        return str
    }
}

extension Date: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        let comp = SQLDateCalendar.mutex.sync { () -> DateComponents in
            let cal = SQLDateCalendar.calendar(forTimezone: option.timeZone)
            return cal.dateComponents([ .year, .month,  .day,  .hour, .minute, .second], from: self)
        } // TODO: in Linux
        
        // YYYY-MM-DD HH:MM:SS
        return QueryParameterWrap( "'\(pad(num: comp.year ?? 0, digits: 4))-\(pad(num: comp.month ?? 0))-\(pad(num: comp.day ?? 0)) \(pad(num: comp.hour ?? 0)):\(pad(num: comp.minute ?? 0)):\(pad(num: comp.second ?? 0))'" )
    }
}

@available(*, deprecated)
public struct SQLDate {
    
    fileprivate let nsDate: Date
    
    public init(_ date: Date) {
        self.nsDate = date
    }
    
    public init(_ timeIntervalSince1970: TimeInterval) {
        self.nsDate = Date(timeIntervalSince1970: timeIntervalSince1970)
    }
}

