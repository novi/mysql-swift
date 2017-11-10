//
//  Query.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Foundation

public protocol QueryParameterType {
    func escaped() -> String
}

public struct SQLString {
    
    public static func escapeId(string str: String) -> String {
        var step1 = ""
        for c in str {
            switch c {
            case "`":
                step1 += "``"
            default:
                step1.append(c)
            }
        }
        var out = ""
        for c in step1 {
            switch c {
            case ".":
                out += "`.`"
            default:
                out.append(c)
            }
        }
        return "`\(out)`"
    }
    
    public static func escape(string str: String) -> String {
        var out = ""
        for c in str.unicodeScalars {
            switch c {
            case "\0":
                out += "\\0"
            case "\n":
                out += "\\n"
            case "\r":
                out += "\\r"
            case "\u{8}":
                out += "\\b"
            case "\t":
                out += "\\t"
            case "\\":
                out += "\\\\"
            case "'":
                out += "\\'"
            case "\"":
                out += "\\\""
            case "\u{1A}":
                out += "\\Z"
            default:
                out.append(Character(c))
            }
        }
        return "'\(out)'"
    }
}

public struct QueryFormatter {
    
    public static func format(query: String, args: [QueryParameterType]) throws -> String {
        
        var placeHolderCount = 0
        
        var formatted = query + ""
        
        var valArgs: [QueryParameterType] = []
        var scanRange = formatted.startIndex..<formatted.endIndex
        
        // format ??
        while true {
            // TODO: use function in Swift.String
            let r1 = formatted.range(of: "??", options: [], range: scanRange, locale: nil)
            let r2 = formatted.range(of: "?", options: [], range: scanRange, locale: nil)
            let r: Range<String.Index>
            if let r1 = r1, let r2 = r2 {
                r = r1.lowerBound <= r2.lowerBound ? r1 : r2
            } else if let rr = r1 ?? r2 {
                r = rr
            } else {
                break
            }
            
            switch formatted[r] {
            case "??":
                if placeHolderCount >= args.count {
                    throw QueryFormatError.queryParameterCountMismatch(query: query)
                }
                guard let val = args[placeHolderCount] as? String else {
                    throw QueryFormatError.queryParameterIdTypeError(query: query)
                }
                formatted.replaceSubrange(r, with: SQLString.escapeId(string: val))
                scanRange = r.upperBound..<formatted.endIndex
            case "?":
                if placeHolderCount >= args.count {
                    throw QueryFormatError.queryParameterCountMismatch(query: query)
                }
                valArgs.append(args[placeHolderCount])
                scanRange = r.upperBound..<formatted.endIndex
            default: break
            }
            
            placeHolderCount += 1
            
            if placeHolderCount >= args.count {
                break
            }
        }
        
        //print(formatted, valArgs)
        
        placeHolderCount = 0
        var formattedChars = Array(formatted)
        var index = 0
        while index < formattedChars.count {
            if formattedChars[index] == "?" {
                if placeHolderCount >= valArgs.count {
                    throw QueryFormatError.queryParameterCountMismatch(query: query)
                }
                let val = valArgs[placeHolderCount]
                formattedChars.remove(at: index)
                let valStr = val.escaped()
                formattedChars.insert(contentsOf: valStr, at: index)
                index += valStr.count - 1
                placeHolderCount += 1
            } else {
                index += 1
            }
        }
        
        return String(formattedChars)
    }
}

