//
//  Date.swift
//  MySQL
//
//  Created by ito on 12/16/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import CoreFoundation

public struct SQLDate {
    let absoluteTime: CFAbsoluteTime
    let timeZone: CFTimeZoneRef
    
    init(absoluteTime: CFAbsoluteTime, timeZone: CFTimeZoneRef) {
        self.absoluteTime = absoluteTime
        self.timeZone = timeZone
    }
    
    init(sqlDate: String, timeZone: CFTimeZoneRef) throws {
        self.timeZone = timeZone
        
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
                if CFGregorianDateIsValid(date, CFGregorianUnitFlags.AllUnits.rawValue) == false {
                    //throw QueryError.InvalidSQLDate(sqlDate)
                }
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
        if num < 0 {
            return str
        }
        while str.characters.count < digits {
            str = "0" + str
        }
        return str
    }
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
        return escapedValue() + " " + (CFTimeZoneGetName(timeZone) as! String)
    }
}

extension SQLDate {
    public static func now(timeZone timeZone: Connection.TimeZone) -> SQLDate {
        return SQLDate(absoluteTime: CFAbsoluteTimeGetCurrent(), timeZone: timeZone.timeZone)
    }
}