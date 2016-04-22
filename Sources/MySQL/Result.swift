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

public func <| <T: SQLStringDecodable>(r: QueryRowResult, key: String) throws -> T {
    return try r.getValue(forKey: key)
}

public func <| <T: SQLStringDecodable>(r: QueryRowResult, index: Int) throws -> T {
    return try r.getValue(at: index)
}

public func <|? <T: SQLStringDecodable>(r: QueryRowResult, key: String) throws -> T? {
    return try r.getValueNullable(forKey: key)
}

public func <|? <T: SQLStringDecodable>(r: QueryRowResult, index: Int) throws -> T? {
    return try r.getValueNullable(at: index)
}

public protocol SQLStringDecodable {
    static func from(string: String) -> Self?
}

public struct QueryRowResult {
    
    let fields: [Connection.Field]
    let cols: [Connection.FieldValue]
    let columnMap: [String: Connection.FieldValue]
    
    init(fields: [Connection.Field], cols: [Connection.FieldValue]) {
        self.fields = fields
        self.cols = cols
        var map:[String: Connection.FieldValue] = [:]
        for i in 0..<cols.count {
            map[fields[i].name] = cols[i]
        }
        self.columnMap = map
    }
    
    func isNull(forKey key: String) -> Bool {
        guard let val = columnMap[key] else {
            return false
        }
        switch val {
        case .Null:
            return true
        case .Binary, .Date:
            return false
        }
    }
    
    func isNull(at index: Int) throws -> Bool {
        try checkFieldBounds(at: index)
        
        switch cols[index] {
        case .Null:
            return true
        case .Binary, .Date:
            return false
        }
    }
    
    func checkFieldBounds(at index: Int) throws {
        guard cols.count > index else {
            throw QueryError.FieldIndexOutOfBounds(fieldCount: cols.count, attemped: index, fieldName: fields[index].name)
        }
    }
    
    func castOrFail<T: SQLStringDecodable>(_ obj: String, key: String) throws -> T {
        //print("casting val \(obj) to \(T.self)")
        guard let val = T.from(string: obj) as T? else {
            throw QueryError.CastError(actual: obj, expected: "\(T.self)", key: key)
        }
        return val
    }
    
    public func getValueNullable<T: SQLStringDecodable>(at index: Int) throws -> T? {
        try checkFieldBounds(at: index)
        
        if try isNull(at: index) {
            return nil
        }
        return try self.getValue(at: index) as T
    }
    
    public func getValueNullable<T: SQLStringDecodable>(forKey key: String) throws -> T? {
        if isNull(forKey: key) {
            return nil
        }
        return try self.getValue(forKey: key) as T
    }
    
    func getValue<T: SQLStringDecodable>(val: Connection.FieldValue, key: String) throws -> T {
        switch val {
        case .Null:
            throw QueryError.CastError(actual: "NULL", expected: "\(T.self)", key: key)
        case .Date(let date):
            guard let val = date as? T else {
                throw QueryError.CastError(actual: "\(date)", expected: "\(T.self)", key: key)
            }
            return val
        case .Binary(let binary):
            if let bin = binary as? T {
                return bin
            }
            return try castOrFail(val.string(), key: key)
        }
    }
    
    public func getValue<T: SQLStringDecodable>(at index: Int) throws -> T {
        try checkFieldBounds(at: index)
        
        return try getValue(val: cols[index], key: "\(index)")
    }
    
    public func getValue<T: SQLStringDecodable>(forKey key: String) throws -> T {
        guard let val = columnMap[key] else {
            throw QueryError.MissingKeyError(key: key)
        }
        return try getValue(val: val, key: key)
    }    
}
