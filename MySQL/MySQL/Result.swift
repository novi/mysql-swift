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

public enum QueryResultError: ErrorType {
    case CastError(actual: String, expected: String, key: String)
    case MissingKeyError(String)
}

public func <| <T>(r: QueryResult, key: String) throws -> T {
    guard let val = r.row[key] as? T else {
        throw QueryResultError.CastError(actual: "\(r.row[key])", expected: "\(T.self)", key: key)
    }
    return val
}


public func <| (r: QueryResult, key: String) throws -> Int {
    guard let val = r.row[key] as? Int else {
        throw QueryResultError.CastError(actual: "\(r.row[key])", expected: "\(Int.self)", key: key)
    }
    return val
}

public func <|? <T>(r: QueryResult, key: String) throws -> T? {
    if r.isNull(key) {
        return nil
    }
    return try r <| key
}


public func <|? (r: QueryResult, key: String) throws -> Int? {
    if r.isNull(key) {
        return nil
    }
    return try r <| key
}

public struct QueryResult {
    
    let row: [String:AnyObject]
    
    func isNull(key: String) -> Bool {
        if row[key] is NSNull {
            return true
        }
        return false
    }
    
    
}
