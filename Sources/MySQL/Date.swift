//
//  Date.swift
//  MySQL
//
//  Created by ito on 12/16/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//


import Foundation
import SQLFormatter

internal final class SQLDateCalendar {
    
    private static var calendars: Atomic<[TimeZone:Calendar]> = Atomic([:])
    
    internal static func calendar<T>(forTimezone timeZone: TimeZone, _ block: (_ calendar: Calendar) -> T) -> T {
        return calendars.syncWriting {
            if let calendar = $0[timeZone] {
                return block(calendar)
            }
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timeZone
            $0[timeZone] = calendar
            return block(calendar)
        }
    }
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


extension Date {
    
    internal init(sqlDate: String, timeZone: TimeZone) throws {
        
        switch sqlDate.count {
        case 19:
            let chars: [Character] = Array(sqlDate)
            if let year = Int(String(chars[0...3])),
                let month = Int(String(chars[5...6])),
                let day = Int(String(chars[8...9])),
                let hour = Int(String(chars[11...12])),
                let minute = Int(String(chars[14...15])),
                let second = Int(String(chars[17...18])), year > 0 && day > 0 && month > 0 {
                var comps = DateComponents()
                comps.year = year
                comps.month = month
                comps.day = day
                comps.hour = hour
                comps.minute = minute
                comps.second = second
                let parsedDate: Date? = SQLDateCalendar.calendar(forTimezone: timeZone) { calendar in
                    calendar.date(from :comps)
                }
                if let date = parsedDate {
                    self = date
                    return
                }
            }
        default: break
        }
        
        throw QueryError.SQLDateStringError(sqlDate)
    }
}

extension Date: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        let comp: DateComponents = SQLDateCalendar.calendar(forTimezone: option.timeZone) { calendar in
            calendar.dateComponents([ .year, .month,  .day,  .hour, .minute, .second], from: self)
        }        
        // YYYY-MM-DD HH:MM:SS
        return EscapedQueryParameter( "'\(pad(num: comp.year ?? 0, digits: 4))-\(pad(num: comp.month ?? 0))-\(pad(num: comp.day ?? 0)) \(pad(num: comp.hour ?? 0)):\(pad(num: comp.minute ?? 0)):\(pad(num: comp.second ?? 0))'" )
    }
}

fileprivate func nanosecondsToString(_ nanosec: Int) -> String {
    let nanosecSecond = Double(nanosec % 1_000_000_000)/1_000_000_000.0
    var nanosecStr = String(format: "%.6f", nanosecSecond)
    nanosecStr.removeFirst()
    return String(nanosecStr)
}

extension DateComponents: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        if let year = self.year, let month = self.month, let day = self.day, let hour = self.hour, let minute = self.minute, let second = self.second {
            var string = "'\(pad(num: year, digits: 4))-\(pad(num: month))-\(pad(num: day)) \(pad(num: hour)):\(pad(num: minute)):\(pad(num: second))"
            if let nanosec = self.nanosecond {
                string += nanosecondsToString(nanosec)
            }
            return EscapedQueryParameter(string + "'")
        }
        
        if let hour = self.hour, let minute = self.minute, let second = self.second {
            var string = "'\(pad(num: hour)):\(pad(num: minute)):\(pad(num: second))"
            if let nanosec = self.nanosecond {
                string += nanosecondsToString(nanosec)
            }
            return EscapedQueryParameter(string + "'")
        }
        if let year = self.year {
            return EscapedQueryParameter("'\(pad(num: year))'")
        }
        throw QueryParameterError.dateComponentsError(self.description)
    }
}

fileprivate let DateTimeRegex: NSRegularExpression = {
    return try! NSRegularExpression(pattern: "^(\\d{4})-(\\d{2})-(\\d{2}) (\\d{2}):(\\d{2}):(\\d{2})\\.?(\\d*)$", options: [])
}()

fileprivate let TimeRegex: NSRegularExpression = {
    return try! NSRegularExpression(pattern: "^(\\-?\\d{1,3}):(\\d{2}):(\\d{2})\\.?(\\d*)$", options: [])
}()

fileprivate let DateRegex: NSRegularExpression = {
    return try! NSRegularExpression(pattern: "^(\\d{4})-(\\d{2})-(\\d{2})$", options: [])
}()


fileprivate func stringToNanoseconds<S: StringProtocol>(_ string: S) -> Int? {
    guard string.count > 0 else {
        return nil
    }
    guard let doubleValue = Double("0.\(string)") else {
        return nil
    }
    return Int(doubleValue * 1_000_000_000.0)
}

extension DateComponents: SQLRawStringDecodable {
    static func fromSQLValue(string: String) throws -> DateComponents {
        if string.count == 4 {
            // YEAR type
            return DateComponents(year: Int(string))
        }
        let wholeRange = NSRange(string.startIndex..<string.endIndex, in: string)
        if let match = DateTimeRegex.firstMatch(in: string, options: [], range: wholeRange) {
            let year = Int(string[Range(match.range(at: 1), in: string)!])
            let month = Int(string[Range(match.range(at: 2), in: string)!])
            let day = Int(string[Range(match.range(at: 3), in: string)!])
            
            let hour = Int(string[Range(match.range(at: 4), in: string)!])
            let minute = Int(string[Range(match.range(at: 5), in: string)!])
            let second = Int(string[Range(match.range(at: 6), in: string)!])
            
            let nanosecond = String(string[Range(match.range(at: 7), in: string)!])
            return DateComponents(
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: stringToNanoseconds(nanosecond)
            )
        }
        if let match = TimeRegex.firstMatch(in: string, options: [], range: wholeRange) {
            let hour = Int(string[Range(match.range(at: 1), in: string)!])
            let minute = Int(string[Range(match.range(at: 2), in: string)!])
            let second = Int(string[Range(match.range(at: 3), in: string)!])
            
            let nanosecond = string[Range(match.range(at: 4), in: string)!]
            return DateComponents(
                hour: hour,
                minute: minute,
                second: second,
                nanosecond: stringToNanoseconds(nanosecond)
            )
        }
        if let match = DateRegex.firstMatch(in: string, options: [], range: wholeRange) {
            let year = Int(string[Range(match.range(at: 1), in: string)!])
            let month = Int(string[Range(match.range(at: 2), in: string)!])
            let day = Int(string[Range(match.range(at: 3), in: string)!])
            return DateComponents(
                year: year,
                month: month,
                day: day
            )
        }
        throw QueryError.SQLDateStringError(string)
    }
}
