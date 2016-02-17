//
//  QueryParameterType.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/28/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public struct QueryDictionary: QueryParameter {
    let dict: [String: QueryParameter?]
    public init(_ dict: [String: QueryParameter?]) {
        self.dict = dict
    }
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        var keyVals: [String] = []
        for (k, v) in dict {
            keyVals.append("\(SQLString.escapeId(k)) = \(try QueryOptional(v).escapedValueWith(option: option))")
        }
        return keyVals.joinWithSeparator(", ")
    }
}

//extension Dictionary: where Value: QueryParameter, Key: StringLiteralConvertible { }
// not yet supported
// extension Array:QueryParameter where Element: QueryParameter { }

protocol QueryArrayType: QueryParameter {
    
}

public struct QueryArray : QueryParameter, QueryArrayType {
    let arr: [QueryParameter?]
    public init(_ arr: [QueryParameter?]) {
        self.arr = arr
    }
    public init(_ arr: [QueryParameter]) {
        self.arr = arr.map { Optional($0) }
    }
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return try arr.map({
            if let val = $0 as? QueryArrayType {
                return "(" + (try val.escapedValueWith(option: option)) + ")"
            }
            return try $0.escapedValueWith(option: option)
        }).joinWithSeparator(", ")
    }
}

extension Optional : QueryParameter {
    
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        guard let value = self else {
            return QueryParameterNull().escapedValueWith(option: option)
        }
        guard let val = value as? QueryParameter else {
            throw QueryError.CastError(actual: "\(value.self)", expected: "QueryParameter", key: "")
        }
        return try val.escapedValueWith(option: option)
    }
}


struct QueryOptional<T: QueryParameter>: QueryParameter {
    let val: T?
    init(_ val: T?) {
        self.val = val
    }
    func escapedValueWith(option option: QueryParameterOption) throws -> String {
        guard let val = self.val else {
            return QueryParameterNull().escapedValueWith(option: option)
        }
        return try val.escapedValueWith(option: option)
    }
}


extension String: QueryParameter {
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return SQLString.escape(self)
    }
}

extension Int: QueryParameter {
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return String(self)
    }
}

extension Int64: QueryParameter {
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return String(self)
    }
}

extension Double: QueryParameter {
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return String(self)
    }
}

extension Float: QueryParameter {
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return String(self)
    }
}

extension Bool: QueryParameter {
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return self ? "true" : "false"
    }
}

extension NSDate: QueryParameter {
    public func escapedValueWith(option option: QueryParameterOption) throws -> String {
        return try SQLDate(self).escapedValueWith(option: option)
    }
}
