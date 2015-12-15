//
//  Query.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//


// inspired
// https://github.com/felixge/node-mysql/blob/master/lib/protocol/SqlString.js

public protocol QueryArgumentValueType {
    func escapedValue() throws -> String
}

public struct QueryArgumentValueDictionary: QueryArgumentValueType {
    let dict: [String: QueryArgumentValueType]
    public init(_ dict: [String: QueryArgumentValueType]) {
        self.dict = dict
    }
    public func escapedValue() throws -> String {
        var keyVals: [String] = []
        for (k, v) in dict {
            keyVals.append("\(SQLString.escapeKeyString(k)) = \(try v.escapedValue())")
        }
        return keyVals.joinWithSeparator(", ")
    }
}

public struct QueryArgumentValueArray: QueryArgumentValueType {
    let vals: [QueryArgumentValueType]
    public init(_ vals: [QueryArgumentValueType]) {
        self.vals = vals
    }
    public func escapedValue() throws -> String {
        return try vals.map({
            if $0 is QueryArgumentValueArray {
                return "(" + (try $0.escapedValue()) + ")"
            }
            return try $0.escapedValue()
        }).joinWithSeparator(", ")
    }
}

public struct QueryArgumentValueString: QueryArgumentValueType {
    let val: String?
    public init(_ val: String?) {
        self.val = val
    }
    
    public func escapedValue() -> String {
        guard let val = self.val else {
            return QueryArgumentValueNull().escapedValue()
        }
        return SQLString.escapeString(val)
    }
}

public struct QueryArgumentValueInt: QueryArgumentValueType {
    let val: Int?
    public init(_ val: Int?) {
        self.val = val
    }
    public func escapedValue() -> String {
        guard let val = self.val else {
            return QueryArgumentValueNull().escapedValue()
        }
        return String(val)
    }
}

public struct QueryArgumentValueNull: QueryArgumentValueType {
    public init() {
        
    }
    public func escapedValue() -> String {
        return "NULL"
    }
}

public struct QueryArgumentValueBool: QueryArgumentValueType {
    let val: Bool?
    public init(_ val: Bool?) {
        self.val = val
    }
    public func escapedValue() -> String {
        guard let val = self.val else {
            return QueryArgumentValueNull().escapedValue()
        }
        return val ? "true" : "false"
    }
}

/*
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
*/

struct SQLString {
    
    static func format(query: String, args: [QueryArgumentValueType]) throws -> String {
        var out: String = ""
        var placeHolderCount: Int = 0
        for c in query.characters {
            switch c {
                case "?":
                    if placeHolderCount >= args.count {
                        throw QueryError.QueryArgumentCountMismatch
                    }
                    let val = args[placeHolderCount]
                out += " " + (try val.escapedValue()) + " "
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
    
    static func escapeKeyString(str: String) -> String {
        // TODO
        return str
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