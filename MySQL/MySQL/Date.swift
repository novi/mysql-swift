//
//  Date.swift
//  MySQL
//
//  Created by ito on 12/16/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import CoreFoundation

public struct SQLDate {
    public let absoluteTime: CFAbsoluteTime
    let timeZone: CFTimeZoneRef
    
    init(absoluteTime: CFAbsoluteTime, timeZoneOffset: CFTimeInterval = 0) {
        self.absoluteTime = absoluteTime
        if timeZoneOffset == 0 {
            self.timeZone = self.dynamicType.UTCTimeZone
        } else {
            self.timeZone = CFTimeZoneCreateWithTimeIntervalFromGMT(nil, timeZoneOffset)
        }
    }
    
    init(sqlDate: String, timeZoneOffset: CFTimeInterval = 0) throws {
        if timeZoneOffset == 0 {
            self.timeZone = self.dynamicType.UTCTimeZone
        } else {
            self.timeZone = CFTimeZoneCreateWithTimeIntervalFromGMT(nil, timeZoneOffset)
        }
        
        if let year = Int32(sqlDate) where sqlDate.characters.count == 4 {
            let date = CFGregorianDate(year: year, month: 1, day: 1, hour: 0, minute: 0, second: 0)
            self.absoluteTime = CFGregorianDateGetAbsoluteTime(date, timeZone)
            return
        }
        let chars:[Character] = Array(sqlDate.characters)
        if let year = Int32(String(chars[0...3])),
            let month = Int8(String(chars[5...6])),
            let day = Int8(String(chars[8...9])),
            let hour = Int8(String(chars[11...12])),
            let minute = Int8(String(chars[14...15])),
            let second = Int8(String(chars[17...18])) where chars.count == 19 {
            let date = CFGregorianDate(year: year, month: month, day: day, hour: hour, minute: minute, second: Double(second))
            self.absoluteTime = CFGregorianDateGetAbsoluteTime(date, timeZone)
            return
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
        while str.characters.count < digits {
            str = "0" + str
        }
        return str
    }
    
    static let UTCTimeZone = CFTimeZoneCreateWithTimeIntervalFromGMT(nil, 0)
}

extension SQLDate: QueryArgumentValueType {
    public func escapedValue() -> String {
        let cal = CFAbsoluteTimeGetGregorianDate(absoluteTime, timeZone)
        // YYYY-MM-DD HH:MM:SS
        return "'\(padNum(cal.year, digits: 4))-\(padNum(cal.month))-\(padNum(cal.day)) \(padNum(cal.hour)):\(padNum(cal.minute)):\(padNum(Int(cal.second)))'"
    }
}

extension SQLDate : CustomStringConvertible {
    public var description: String {
        return escapedValue() + " " + (CFTimeZoneGetName(timeZone) as String)
    }
}

extension Connection {
    public func now() -> SQLDate {
        return SQLDate(absoluteTime: CFAbsoluteTimeGetCurrent(), timeZoneOffset: Double(options.timeZone))
    }
    
    public func date(absoluteTime absoluteTime:CFAbsoluteTime) -> SQLDate {
        return SQLDate(absoluteTime: absoluteTime, timeZoneOffset: Double(options.timeZone))
    }
}