//
//  Result.swift
//  MySQL
//
//  Created by ito on 12/10/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Foundation

precedencegroup DecodingPrecedence {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator <| : DecodingPrecedence
infix operator <|? : DecodingPrecedence


public protocol QueryRowResultType {
    static func decodeRow(r: QueryRowResult) throws -> Self
}

public func <| <T: SQLStringDecodable>(r: QueryRowResult, field: String) throws -> T {
    return try r.getValue(forField: field)
}

public func <| <T: SQLStringDecodable>(r: QueryRowResult, index: Int) throws -> T {
    return try r.getValue(at: index)
}

public func <|? <T: SQLStringDecodable>(r: QueryRowResult, field: String) throws -> T? {
    return try r.getValueNullable(forField: field)
}

public func <|? <T: SQLStringDecodable>(r: QueryRowResult, index: Int) throws -> T? {
    return try r.getValueNullable(at: index)
}

public protocol SQLStringDecodable {
    static func fromSQL(string: String) throws -> Self
}

public struct QueryRowResult {
    
    let fields: [Connection.Field]
    let cols: [Connection.FieldValue]
    let columnMap: [String: Connection.FieldValue] // the key is field name
    
    init(fields: [Connection.Field], cols: [Connection.FieldValue]) {
        self.fields = fields
        self.cols = cols
        var map:[String: Connection.FieldValue] = [:]
        for i in 0..<cols.count {
            map[fields[i].name] = cols[i]
        }
        self.columnMap = map
    }
    
    func isNull(forField field: String) -> Bool {
        guard let val = columnMap[field] else {
            return false
        }
        switch val {
        case .null:
            return true
        case .binary, .date:
            return false
        }
    }
    
    func isNull(at index: Int) throws -> Bool {
        try checkFieldBounds(at: index)
        
        switch cols[index] {
        case .null:
            return true
        case .binary, .date:
            return false
        }
    }
    
    func checkFieldBounds(at index: Int) throws {
        guard cols.count > index else {
            throw QueryError.fieldIndexOutOfBounds(fieldCount: cols.count, attemped: index, fieldName: fields[index].name)
        }
    }
    
    func castOrFail<T: SQLStringDecodable>(_ obj: String, field: String) throws -> T {
        //print("casting val \(obj) to \(T.self)")
        do {
            return try T.fromSQL(string: obj)
        } catch {
            throw QueryError.SQLStringDecodeError(error: error, actualValue: obj, expectedType: "\(T.self)", field: field)
        }
    }
    
    public func getValueNullable<T: SQLStringDecodable>(at index: Int) throws -> T? {
        try checkFieldBounds(at: index)
        
        if try isNull(at: index) {
            return nil
        }
        return try self.getValue(at: index) as T
    }
    
    public func getValueNullable<T: SQLStringDecodable>(forField field: String) throws -> T? {
        if isNull(forField: field) {
            return nil
        }
        return try self.getValue(forField: field) as T
    }
    
    func getValue<T: SQLStringDecodable>(val: Connection.FieldValue, field: String) throws -> T {
        switch val {
        case .null:
            throw QueryError.castError(actualValue: "NULL", expectedType: "\(T.self)", field: field)
        case .date(let date):
            guard let val = date as? T else {
                throw QueryError.castError(actualValue: "\(date)", expectedType: "\(T.self)", field: field)
            }
            return val
        case .binary(let data):
            //print("T is \(T.self)")
            if let bin = data as? T {
                return bin
            }
            return try castOrFail(val.string(), field: field)
        }
    }
    
    public func getValue<T: SQLStringDecodable>(at index: Int) throws -> T {
        try checkFieldBounds(at: index)
        
        return try getValue(val: cols[index], field: "\(index)")
    }
    
    public func getValue<T: SQLStringDecodable>(forField field: String) throws -> T {
        guard let val = columnMap[field] else {
            throw QueryError.missingField(field: field)
        }
        return try getValue(val: val, field: field)
    }    
}
