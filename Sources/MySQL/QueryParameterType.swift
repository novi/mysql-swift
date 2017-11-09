//
//  QueryParameterType.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/28/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public protocol QueryParameter {
    func queryParameter(option: QueryParameterOption) throws -> QueryParameterType
    var omitOnQueryParameter: Bool { get }
}

public extension QueryParameter {
    var omitOnQueryParameter: Bool {
        return false
    }
}

public protocol QueryParameterDictionaryType: QueryParameter {
    func queryParameter() throws -> QueryDictionary
}

public extension QueryParameterDictionaryType {
    func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return try queryParameter().queryParameter(option: option)
    }
}

public protocol QueryParameterOptionType {
}


public struct QueryParameterNull: QueryParameter, ExpressibleByNilLiteral {
    
    public init() {
        
    }
    public init(nilLiteral: ()) {
        
    }
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( "NULL" )
    }
}

public struct QueryDictionary: QueryParameter {
    let dict: [String: QueryParameter?]
    public init(_ dict: [String: QueryParameter?]) {
        self.dict = dict
    }
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        var keyVals: [String] = []
        for (k, v) in dict {
            if v == nil || v?.omitOnQueryParameter == false {
                keyVals.append("\(SQLString.escapeId(string: k)) = \(try QueryOptional(v).queryParameter(option: option).escaped())")
            }
        }
        return QueryParameterWrap( keyVals.joined(separator:  ", ") )
    }
}

//extension Dictionary: where Value: QueryParameter, Key: StringLiteralConvertible { }
// not yet supported
// extension Array:QueryParameter where Element: QueryParameter { }


protocol QueryArrayType: QueryParameter {
    
}

public struct QueryArray: QueryParameter, QueryArrayType {
    let arr: [QueryParameter?]
    public init(_ arr: [QueryParameter?]) {
        self.arr = arr
    }
    public init(_ arr: [QueryParameter]) {
        self.arr = arr.map { Optional($0) }
    }
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return QueryParameterWrap( try arr.filter({ val in
            if let valid = val {
                return valid.omitOnQueryParameter == false
            }
            return true
        }).map({
            if let val = $0 as? QueryArrayType {
                return "(" + (try val.queryParameter(option: option).escaped()) + ")"
            }
            return try QueryOptional($0).queryParameter(option: option).escaped()
        }).joined(separator: ", ") )
    }
}



extension Optional: QueryParameter {
    
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        guard let value = self else {
            return QueryParameterNull().queryParameter(option: option)
        }
        guard let val = value as? QueryParameter else {
            throw QueryFormatError.castError(actual: "\(value.self)", expected: "QueryParameter", key: "")
        }
        return try val.queryParameter(option: option)
    }
    public var omitOnQueryParameter: Bool {
        guard let value = self else {
            return false
        }
        guard let val = value as? QueryParameter else {
            return false
        }
        return val.omitOnQueryParameter
    }
}


struct QueryOptional: QueryParameter {
    let val: QueryParameter?
    init(_ val: QueryParameter?) {
        self.val = val
    }
    func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        guard let val = self.val else {
            return QueryParameterNull().queryParameter(option: option)
        }
        return try val.queryParameter(option: option)
    }
    var omitOnQueryParameter: Bool {
        return val?.omitOnQueryParameter ?? false
    }
}

struct QueryParameterWrap: QueryParameterType {
    let val: String
    init(_ val: String) {
        self.val = val
    }
    func escaped() -> String {
        return val
    }
}

extension String: QueryParameterType {
    public func escaped() -> String {
        return SQLString.escape(string: self)
    }
}

extension String: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( SQLString.escape(string: self) )
    }
}

extension Int: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension UInt: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension Int64: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension Int32: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension Int16: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension Int8: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension UInt64: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension UInt32: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension UInt16: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension UInt8: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension Double: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension Float: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( String(self) )
    }
}

extension Bool: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return QueryParameterWrap( self ? "true" : "false" )
    }
}
