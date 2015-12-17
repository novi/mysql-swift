//
//  Result.swift
//  MySQL
//
//  Created by ito on 12/10/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

infix operator <| { associativity left precedence 150 }
infix operator <|? { associativity left precedence 150 }

public protocol QueryResultRowType {
    //typealias QueryResultType = Self
    static func decodeRow(r: QueryResult) throws -> Self //.QueryResultType
}

public func <| <T>(r: QueryResult, key: String) throws -> T {
    return try r.getValue(key)
}

public func <| <T>(r: QueryResult, index: Int) throws -> T {
    return try r.getValue(index)
}

public func <|? <T>(r: QueryResult, key: String) throws -> T? {
    return try r.getValueNullable(key)
}

public func <|? <T>(r: QueryResult, index: Int) throws -> T? {
    return try r.getValueNullable(index)
}

public struct QueryResult {
    
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
    
    // TODO: check bounds of array
    
    public func getValueNullable<T>(index: Int) throws -> T? {
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
        guard let obj = row.1[index] as Any? else {
            throw QueryError.MissingKeyError(key: "\(index)")
        }
        guard let val = obj as? T else {
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
