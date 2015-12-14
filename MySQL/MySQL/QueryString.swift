//
//  Query.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//


// inspired
// https://github.com/felixge/node-mysql/blob/master/lib/protocol/SqlString.js

struct SQLValue {
    let val: Any?
    init(_ val: Any?) {
        self.val = val
    }
    
    func escape() throws -> String {
        switch val {
        case nil:
            return "NULL"
        case let v as Bool:
            return v ? "true" : "false"
        case let v as Int:
            return String(v)
        case let v as String:
            return SQLString.escapeString(v)
        default:
            throw QueryError.UnsupportedQueryArgumentType("\(val.self)")
        }
    }
}

struct SQLString {
    
    static func format(query: String, args: [Any?]) throws -> String {
        var out: String = ""
        var placeHolderCount: Int = 0
        for c in query.characters {
            switch c {
                case "?":
                    if placeHolderCount >= args.count {
                        throw QueryError.QueryArgumentCountMismatch
                    }
                    let val = SQLValue(args[placeHolderCount])
                out += " " + (try val.escape()) + " "
                placeHolderCount += 1
            default:
                out += String(c)
            }
        }
        if placeHolderCount != args.count {
            throw QueryError.QueryArgumentCountMismatch
        }
        return out
    }
    
    static func escapeString(str: String) -> String {
        var out: String = ""
        for c in str.characters {
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
                out += String(c)
            }
        }
        return "'" + out + "'"
    }
}