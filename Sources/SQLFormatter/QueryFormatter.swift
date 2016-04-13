//
//  Query.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Foundation


#if os(OSX)
#else
    extension String {
        public func range(of string: String, options mask: NSStringCompareOptions, range searchRange: Range<Index>?, locale: NSLocale?) -> Range<Index>? {
            return rangeOfString(string, options: mask, range: searchRange, locale: locale)
        }
    }
    
#endif

public protocol QueryParameterType {
    func escapedValue() -> String
}

public struct SQLString {
    
    public static func escapeId(str: String) -> String {
        var step1: [Character] = []
        for c in str.characters {
            switch c {
                case "`":
                step1.append(contentsOf: "``".characters)
            default:
                step1.append(c)
            }
        }
        var out: [Character] = []
        for c in step1 {
            switch c {
                case ".":
                out.append(contentsOf: "`.`".characters)
                default:
                out.append(c)
            }
        }
        return "`" + String(out) + "`"
    }
    
    public static func escape(str: String) -> String {
        var out: [Character] = []
        for c in str.unicodeScalars {
            switch c {
            case "\0":
                out.append(contentsOf: "\\0".characters)
            case "\n":
                out.append(contentsOf: "\\n".characters)
            case "\r":
                out.append(contentsOf: "\\r".characters)
            case "\u{8}":
                out.append(contentsOf: "\\b".characters)
            case "\t":
                out.append(contentsOf: "\\t".characters)
            case "\\":
                out.append(contentsOf: "\\\\".characters)
            case "'":
                out.append(contentsOf: "\\'".characters)
            case "\"":
                out.append(contentsOf: "\\\"".characters)
            case "\u{1A}":
                out.append(contentsOf: "\\Z".characters)
            default:
                out.append(Character(c))
            }
        }
        return "'" + String(out) + "'"
    }
}

public struct QueryFormatter {
    
    public static func format(query: String, args: [QueryParameterType]) throws -> String {
        
        var placeHolderCount: Int = 0
        
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
                r = r1.startIndex <= r2.startIndex ? r1 : r2
            } else if let rr = r1 ?? r2 {
                r = rr
            } else {
                break
            }
            
            switch formatted[r] {
            case "??":
                if placeHolderCount >= args.count {
                    throw QueryFormatError.QueryParameterCountMismatch(query: query)
                }
                guard let val = args[placeHolderCount] as? String else {
                    throw QueryFormatError.QueryParameterIdTypeError(query: query)
                }
                formatted.replaceSubrange(r, with: SQLString.escapeId(val))
                scanRange = r.endIndex..<formatted.endIndex
            case "?":
                if placeHolderCount >= args.count {
                    throw QueryFormatError.QueryParameterCountMismatch(query: query)
                }
                valArgs.append(args[placeHolderCount])
                scanRange = r.endIndex..<formatted.endIndex
            default: break
            }
            
            placeHolderCount += 1
            
            if placeHolderCount >= args.count {
                break
            }
        }
        
        //print(formatted, valArgs)
        
        placeHolderCount = 0
        var formattedChars = Array(formatted.characters)
        var index: Int = 0
        while index < formattedChars.count {
            if formattedChars[index] == "?" {
                if placeHolderCount >= valArgs.count {
                    throw QueryFormatError.QueryParameterCountMismatch(query: query)
                }
                let val = valArgs[placeHolderCount]
                formattedChars.remove(at: index)
                let valStr = val.escapedValue()
                formattedChars.insert(contentsOf: valStr.characters, at: index)
                index += valStr.characters.count-1
                placeHolderCount += 1
            } else {
                index += 1
            }
        }
        
        return String(formattedChars)
    }
}

