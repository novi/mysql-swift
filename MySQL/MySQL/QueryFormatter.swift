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

public struct QueryDictionary: QueryArgumentValueType {
    let dict: [String: QueryArgumentValueType?]
    public init(_ dict: [String: QueryArgumentValueType?]) {
        self.dict = dict
    }
    public func escapedValue() throws -> String {
        var keyVals: [String] = []
        for (k, v) in dict {
            keyVals.append("\(SQLString.escapeIdString(k)) = \(try QueryOptional(v).escapedValue())")
        }
        return keyVals.joinWithSeparator(", ")
    }
}

//extension Dictionary: where Value: QueryArgumentValueType, Key: StringLiteralConvertible { }
// not yet supported
// extension Array:QueryArgumentValueType where Element: QueryArgumentValueType { }


public struct QueryArray: QueryArgumentValueType {
    let arr: [QueryArgumentValueType?]
    public init(_ arr: [QueryArgumentValueType?]) {
        self.arr = arr
    }
    public func escapedValue() throws -> String {
        return try arr.map({
            if let arr = $0 as? QueryArray {
                return "(" + (try arr.escapedValue()) + ")"
            }
            return try QueryOptional($0).escapedValue()
        }).joinWithSeparator(", ")
    }
}

extension String: QueryArgumentValueType {
    public func escapedValue() -> String {
        return SQLString.escapeString(self)
    }
}

extension Int: QueryArgumentValueType {
    public func escapedValue() -> String {
        return String(self)
    }
}

public struct QueryOptional: QueryArgumentValueType {
    let val: QueryArgumentValueType?
    public init(_ val: QueryArgumentValueType?) {
        self.val = val
    }
    public func escapedValue() throws -> String {
        guard let val = self.val else {
            return QueryArgumentValueNull().escapedValue()
        }
        return try val.escapedValue()
    }
}

//extension Optional where Wrapped: QueryArgumentValueType, Optional: QueryArgumentValueType {
    /*public func escapedValue() throws -> String {
        switch self {
        case .None:
            return QueryArgumentValueNull().escapedValue()
        case .Some(let val):
            return try val.escapedValue()
        }
    }*/
//}

/*extension Optional where Wrapped: String {
    public func escapedValue() -> String {
        switch self {
        case .None:
            return QueryArgumentValueNull().escapedValue()
        case .Some(let val):
            return val
        }
    }
}
*/

public struct QueryArgumentValueNull: QueryArgumentValueType, NilLiteralConvertible {
    public init() {
        
    }
    public init(nilLiteral: ()) {
        
    }
    public func escapedValue() -> String {
        return "NULL"
    }
}

extension Bool: QueryArgumentValueType {
    public func escapedValue() -> String {
        return self ? "true" : "false"
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
    static func escapeIdString(str: String) -> String {
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

public struct QueryFormatter {
    
    public static func format(query: String, args: [QueryArgumentValueType]) throws -> String {
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
}


extension Connection {
    
    public func query<T: QueryResultRowType>(query: String, _ args:[QueryArgumentValueType] = []) throws -> ([T], QueryStatus) {
        return try self.query(query: try QueryFormatter.format(query, args: args))
    }
    
    public func query<T: QueryResultRowType>(query: String, _ args:[QueryArgumentValueType] = []) throws -> [T] {
        let (rows, _) = try self.query(query, args) as ([T], QueryStatus)
        return rows
    }
    
    public func query(query: String, _ args:[QueryArgumentValueType] = []) throws -> QueryStatus {
        let (_, status) = try self.query(query, args) as ([EmptyRowResult], QueryStatus)
        return status
    }
}