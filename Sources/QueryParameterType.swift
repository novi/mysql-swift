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

extension Int64: QueryParameter {
    public func escapedValue() -> String {
        return String(self)
    }
}

extension Double: QueryParameter {
    public func escapedValue() -> String {
        return String(self)
    }
}

extension Float: QueryParameter {
    public func escapedValue() -> String {
        return String(self)
    }
}

extension Bool: QueryParameter {
    public func escapedValue() -> String {
        return self ? "true" : "false"
    }
}
