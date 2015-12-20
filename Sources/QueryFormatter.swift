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

public protocol QueryArgumentDictionaryType: QueryArgumentValueType {
    func queryValues() throws -> QueryDictionary
}

public extension QueryArgumentDictionaryType {
    func escapedValue() throws -> String {
        return try queryValues().escapedValue()
    }
}

public struct QueryDictionary: QueryArgumentValueType {
    let dict: [String: QueryArgumentValueType?]
    public init(_ dict: [String: QueryArgumentValueType?]) {
        self.dict = dict
    }
    public func escapedValue() throws -> String {
        var keyVals: [String] = []
        for (k, v) in dict {
            keyVals.append("\(SQLString.escapeId(k)) = \(try QueryOptional(v).escapedValue())")
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
    public init(_ arr: [QueryArgumentValueType]) {
        self.arr = arr.map { QueryOptional($0) }
    }
    public init(_ arr: [Int]) {
        self.arr = arr.map { $0 as QueryArgumentValueType }
    }
    public init(_ arr: [String]) {
        self.arr = arr.map { $0 as QueryArgumentValueType }
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
        return SQLString.escape(self)
    }
}

extension Int: QueryArgumentValueType {
    public func escapedValue() -> String {
        return String(self)
    }
}

extension Bool: QueryArgumentValueType {
    public func escapedValue() -> String {
        return self ? "true" : "false"
    }
}

extension Optional : QueryArgumentValueType {
    
    public func escapedValue() throws -> String {
        guard let value = self else {
            return QueryArgumentValueNull().escapedValue()
        }
        guard let val = value as? QueryArgumentValueType else {
            throw QueryError.CastError(actual: "\(value.self)", expected: "QueryArgumentValueType", key: "")
        }
        return try val.escapedValue()
    }
}


struct QueryOptional: QueryArgumentValueType {
    let val: QueryArgumentValueType?
    init(_ val: QueryArgumentValueType?) {
        self.val = val
    }
    func escapedValue() throws -> String {
        guard let val = self.val else {
            return QueryArgumentValueNull().escapedValue()
        }
        return try val.escapedValue()
    }
}


public struct QueryArgumentValueNull: QueryArgumentValueType, NilLiteralConvertible {
    public init() {
        
    }
    public init(nilLiteral: ()) {
        
    }
    public func escapedValue() -> String {
        return "NULL"
    }
}


struct SQLString {
    static func escapeId(str: String) -> String {
        var step1: [Character] = []
        for c in str.characters {
            switch c {
                case "`":
                step1.appendContentsOf("``".characters)
            default:
                step1.append(c)
            }
        }
        var out: [Character] = []
        for c in step1 {
            switch c {
                case ".":
                out.appendContentsOf("`.`".characters)
                default:
                out.append(c)
            }
        }
        return "`" + String(out) + "`"
    }
    
    static func escape(str: String) -> String {
        var out: [Character] = []
        for c in str.characters {
            switch c {
            case "\0":
                out.appendContentsOf("\\0".characters)
            case "\n":
                out.appendContentsOf("\\n".characters)
            case "\r":
                out.appendContentsOf("\\r".characters)
            case "\u{8}":
                out.appendContentsOf("\\b".characters)
            case "\t":
                out.appendContentsOf("\\t".characters)
            case "\\":
                out.appendContentsOf("\\\\".characters)
            case "'":
                out.appendContentsOf("\\'".characters)
            case "\"":
                out.appendContentsOf("\\\"".characters)
            case "\u{1A}":
                out.appendContentsOf("\\Z".characters)
            default:
                out.append(c)
            }
        }
        return "'" + String(out) + "'"
    }
}

public struct QueryFormatter {
    
    public static func format<S: SequenceType where S.Generator.Element == QueryArgumentValueType>(query: String, args argsg: S) throws -> String {
        var args: [QueryArgumentValueType] = []
        for a in argsg {
            args.append(a)
        }
        
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
    
    public func query<T: QueryResultRowType>(query: String, _ args: [QueryArgumentValueType] = []) throws -> ([T], QueryStatus) {
        return try self.query(query: try QueryFormatter.format(query, args: args))
    }
    
    public func query<T: QueryResultRowType>(query: String, _ args: [QueryArgumentValueType] = []) throws -> [T] {
        let (rows, _) = try self.query(query, args) as ([T], QueryStatus)
        return rows
    }
    
    public func query(query: String, _ args: [QueryArgumentValueType] = []) throws -> QueryStatus {
        let (_, status) = try self.query(query, args) as ([EmptyRowResult], QueryStatus)
        return status
    }
}