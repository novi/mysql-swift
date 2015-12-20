//
//  Result.swift
//  MySQL
//
//  Created by ito on 12/10/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

infix operator <| { associativity left precedence 150 }
infix operator <|? { associativity left precedence 150 }

public protocol QueryRowResultType {
    //typealias QueryResultType = Self
    static func decodeRow(r: QueryRowResult) throws -> Self //.QueryResultType
}

public func <| <T>(r: QueryRowResult, key: String) throws -> T {
    return try r.getValue(key)
}

public func <| <T>(r: QueryRowResult, index: Int) throws -> T {
    return try r.getValue(index)
}

public func <|? <T>(r: QueryRowResult, key: String) throws -> T? {
    return try r.getValueNullable(key)
}

public func <|? <T>(r: QueryRowResult, index: Int) throws -> T? {
    return try r.getValueNullable(index)
}

public struct QueryRowResult {
    
    let row: ([String:Any], [Any])
    
    init(_ row: ([String:Any], [Any])) {
        self.row = row
    }
    
    func isNull(key: String) -> Bool {
        if row.0[key] is Connection.NullValue {
            return true
        }
        return false
    }
    
    func checkFieldBounds(index: Int) throws {
        guard row.1.count > index else {
            throw QueryError.FieldIndexOutOfBounds(fieldCount: row.1.count, attemped: index)
        }
    }
    
    public func getValueNullable<T>(index: Int) throws -> T? {
        try checkFieldBounds(index)
        
        if row.1[index] is Connection.NullValue {
            return nil
        }
        return try self.getValue(index) as T
    }
    
    public func getValueNullable<T>(key: String) throws -> T? {
        if isNull(key) {
            return nil
        }
        return try self.getValue(key) as T
    }
    
    public func getValue<T>(index: Int) throws -> T {
        try checkFieldBounds(index)
        guard let val = row.1[index] as? T else {
            throw QueryError.CastError(actual: "\(row.1[index])", expected: "\(T.self)", key: "\(index)")
        }
        return val
    }
    
    public func getValue<T>(key: String) throws -> T {
        guard let obj = row.0[key] as Any? else {
            throw QueryError.MissingKeyError(key: key)
        }
        guard let val = obj as? T else {
            throw QueryError.CastError(actual: "\(row.0[key])", expected: "\(T.self)", key: key)
        }
        return val
    }    
}
