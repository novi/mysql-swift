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

public func <| <T: StringConstructible>(r: QueryRowResult, key: String) throws -> T {
    return try r.getValue(key)
}

public func <| <T: StringConstructible>(r: QueryRowResult, index: Int) throws -> T {
    return try r.getValue(index)
}

public func <|? <T: StringConstructible>(r: QueryRowResult, key: String) throws -> T? {
    return try r.getValueNullable(key)
}

public func <|? <T: StringConstructible>(r: QueryRowResult, index: Int) throws -> T? {
    return try r.getValueNullable(index)
}

public protocol StringConstructible {
    static func from(string string: String) -> Self?
}

public struct QueryRowResult {
    
    let fields: [Connection.Field]
    let cols: [Any]
    let columnMap: [String: Any]
    
    init(fields: [Connection.Field], cols: [Any]) {
        self.fields = fields
        self.cols = cols
        var map:[String: Any] = [:]
        for i in 0..<cols.count {
            map[fields[i].name] = cols[i]
        }
        self.columnMap = map
    }
    
    func isNull(key: String) -> Bool {
        if columnMap[key] is Connection.NullValue {
            return true
        }
        return false
    }
    
    func checkFieldBounds(index: Int) throws {
        guard cols.count > index else {
            throw QueryError.FieldIndexOutOfBounds(fieldCount: cols.count, attemped: index)
        }
    }
    
    func castOrFail<T: StringConstructible>(obj: String, key: String) throws -> T {
        guard let val = T.from(string: obj) as T? else {
            throw QueryError.CastError(actual: obj, expected: "\(T.self)", key: key)
        }
        return val
    }
    
    public func getValueNullable<T: StringConstructible>(index: Int) throws -> T? {
        try checkFieldBounds(index)
        
        if cols[index] is Connection.NullValue {
            return nil
        }
        return try self.getValue(index) as T
    }
    
    public func getValueNullable<T: StringConstructible>(key: String) throws -> T? {
        if isNull(key) {
            return nil
        }
        return try self.getValue(key) as T
    }
    
    public func getValue<T: StringConstructible>(index: Int) throws -> T {
        try checkFieldBounds(index)
        if let obj = cols[index] as? T {
            return obj
        }
        let key = "\(index)"
        guard let val = cols[index] as? String else {
            throw QueryError.CastError(actual: "\(cols[index])", expected: "\(String.self)", key: key)
        }
        return try castOrFail(val, key: key)
    }
    
    public func getValue<T: StringConstructible>(key: String) throws -> T {
        if let obj = columnMap[key] as? T {
            return obj
        }
        if columnMap[key] == nil {
            throw QueryError.MissingKeyError(key: key)
        }
        guard let obj = columnMap[key] as? String else {
            throw QueryError.CastError(actual: "\(columnMap[key])", expected: "\(String.self)", key: key)
        }
        return try castOrFail(obj, key: key)
    }    
}
