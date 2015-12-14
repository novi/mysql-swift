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
    static func fromRow(r: QueryResult) throws -> Self //.QueryResultType
}

public func <| <T>(r: QueryResult, key: String) throws -> T {
    return try r.getValue(key)
}

public func <|? <T>(r: QueryResult, key: String) throws -> T? {
    return try r.getValueNullable(key)
}

public struct QueryResult {
    
    let row: [String:AnyObject]
    
    func isNull(key: String) -> Bool {
        if row[key] is Connection.NullValue {
            return true
        }
        return false
    }
    
    public func getValueNullable<T>(key: String) throws -> T? {
        if isNull(key) {
            return nil
        }
        return try self.getValue(key) as T
    }
    
    public func getValue<T>(key: String) throws -> T {
        guard let obj = row[key] as AnyObject? else {
            throw QueryError.MissingKeyError(key: key)
        }
        guard let val = obj as? T else {
            throw QueryError.CastError(actual: "\(row[key])", expected: "\(T.self)", key: key)
        }
        return val
    }
    
}
