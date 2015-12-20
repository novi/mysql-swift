//
//  Query.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//


// inspired
// https://github.com/felixge/node-mysql/blob/master/lib/protocol/SqlString.js

public protocol QueryParameter {
    func escapedValue() throws -> String
}

public protocol QueryParameterDictionaryType: QueryParameter {
    func queryParameter() throws -> QueryDictionary
}

public extension QueryParameterDictionaryType {
    func escapedValue() throws -> String {
        return try queryParameter().escapedValue()
    }
}

public struct QueryDictionary: QueryParameter {
    let dict: [String: QueryParameter?]
    public init(_ dict: [String: QueryParameter?]) {
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

//extension Dictionary: where Value: QueryParameter, Key: StringLiteralConvertible { }
// not yet supported
// extension Array:QueryParameter where Element: QueryParameter { }

protocol QueryArrayType: QueryParameter {
    
}

public struct QueryArray<T: QueryParameter> : QueryParameter, QueryArrayType {
    let arr: [T?]
    public init(_ arr: [T?]) {
        self.arr = arr
    }
    public init(_ arr: [T]) {
        self.arr = arr.map { Optional($0) }
    }
    public func escapedValue() throws -> String {
        return try arr.map({
            if let val = $0 as? QueryArrayType {
                return "(" + (try val.escapedValue()) + ")"
            }
            return try $0.escapedValue()
        }).joinWithSeparator(", ")
    }
}

extension String: QueryParameter {
    public func escapedValue() -> String {
        return SQLString.escape(self)
    }
}

extension Int: QueryParameter {
    public func escapedValue() -> String {
        return String(self)
    }
}

extension Bool: QueryParameter {
    public func escapedValue() -> String {
        return self ? "true" : "false"
    }
}

extension Optional : QueryParameter {
    
    public func escapedValue() throws -> String {
        guard let value = self else {
            return QueryParameterNull().escapedValue()
        }
        guard let val = value as? QueryParameter else {
            throw QueryError.CastError(actual: "\(value.self)", expected: "QueryParameter", key: "")
        }
        return try val.escapedValue()
    }
}


struct QueryOptional<T: QueryParameter>: QueryParameter {
    let val: T?
    init(_ val: T?) {
        self.val = val
    }
    func escapedValue() throws -> String {
        guard let val = self.val else {
            return QueryParameterNull().escapedValue()
        }
        return try val.escapedValue()
    }
}


public struct QueryParameterNull: QueryParameter, NilLiteralConvertible {
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
    
    public static func format<S: SequenceType where S.Generator.Element == QueryParameter>(query: String, args argsg: S) throws -> String {
        var args: [QueryParameter] = []
        for a in argsg {
            args.append(a)
        }
        
        var out: String = ""
        var placeHolderCount: Int = 0
        for c in query.characters {
            switch c {
                case "?":
                    if placeHolderCount >= args.count {
                        throw QueryError.QueryParameterCountMismatch
                    }
                    let val = args[placeHolderCount]
                out += " " + (try val.escapedValue()) + " "
                placeHolderCount += 1
            default:
                out += String(c)
            }
        }
        if placeHolderCount != args.count {
            throw QueryError.QueryParameterCountMismatch
        }
        return out
    }
}

extension Connection {
    
    public func query<T: QueryRowResultType>(query: String, _ args: [QueryParameter] = []) throws -> ([T], QueryStatus) {
        return try self.query(query: try QueryFormatter.format(query, args: args))
    }
    
    public func query<T: QueryRowResultType>(query: String, _ args: [QueryParameter] = []) throws -> [T] {
        let (rows, _) = try self.query(query, args) as ([T], QueryStatus)
        return rows
    }
    
    public func query(query: String, _ args: [QueryParameter] = []) throws -> QueryStatus {
        let (_, status) = try self.query(query, args) as ([EmptyRowResult], QueryStatus)
        return status
    }
}