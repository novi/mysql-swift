//
//  Query.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Foundation

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
        
        var placeHolderCount: Int = 0
        
        var formatted = query + ""
        while let r = formatted.rangeOfString("??") {
            if placeHolderCount >= args.count {
                throw QueryError.QueryParameterCountMismatch
            }
            guard let val = args[placeHolderCount] as? String else {
                throw QueryError.QueryParameterIdTypeError
            }
            formatted.replaceRange(r, with: SQLString.escapeId(val))
            placeHolderCount += 1
        }
        
        while let r = formatted.rangeOfString("?") {
            if placeHolderCount >= args.count {
                throw QueryError.QueryParameterCountMismatch
            }
            let val = args[placeHolderCount]
            formatted.replaceRange(r, with: try val.escapedValue())
            placeHolderCount += 1
        }
        if placeHolderCount != args.count {
            throw QueryError.QueryParameterCountMismatch
        }
        return formatted
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