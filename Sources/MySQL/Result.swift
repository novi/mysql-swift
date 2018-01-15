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

// For Decodable pattern
struct QueryRowResultDecoder : Decoder {
    let codingPath = [CodingKey]()
    let userInfo = [CodingUserInfoKey : Any]()
    let row: QueryRowResult
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        return KeyedDecodingContainer(RowKeyedDecodingContainer<Key>(decoder: self))
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw QueryError.initializationErrorMessage(message: "Decoder unkeyedContainer not implemented")
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw QueryError.initializationErrorMessage(message: "Decoder singleValueContainer not implemented")
    }
}

fileprivate struct SQLStringDecoder: Decoder {
    let codingPath =  [CodingKey]()
    let userInfo = [CodingUserInfoKey : Any]()
    let sqlString: String
    
    struct SingleValue: SingleValueDecodingContainer {
        let codingPath =  [CodingKey]()
        let sqlString: String
        func decodeNil() -> Bool {
            fatalError()
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            fatalError()
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            return try Int.fromSQL(string: sqlString)
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            return try Int8.fromSQL(string: sqlString)
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            return try Int16.fromSQL(string: sqlString)
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            return try Int32.fromSQL(string: sqlString)
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            return try Int64.fromSQL(string: sqlString)
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            return try UInt.fromSQL(string: sqlString)
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try UInt8.fromSQL(string: sqlString)
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try UInt16.fromSQL(string: sqlString)
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try UInt32.fromSQL(string: sqlString)
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try UInt64.fromSQL(string: sqlString)
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            fatalError()
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            fatalError()
        }
        
        func decode(_ type: String.Type) throws -> String {
            return sqlString
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            fatalError()
        }
        
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        throw QueryError.initializationErrorMessage(message: "RawTypeDecoder container(keyedBy:) not implemented")
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw QueryError.initializationErrorMessage(message: "RawTypeDecoder unkeyedContainer not implemented")
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValue(sqlString: sqlString)
    }
 }

fileprivate struct RowKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
    typealias Key = K
    
    let decoder : QueryRowResultDecoder
    
    let allKeys = [Key]()
    
    let codingPath = [CodingKey]()
    
    func decodeNil(forKey key: K) throws -> Bool {
        return false
    }
    
    func contains(_ key: K) -> Bool {
        return decoder.row.columnMap[key.stringValue] != nil && !decoder.row.isNull(forField: key.stringValue)
    }
    
    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return try decoder.row.getValue(forField: key.stringValue)
    }
    
    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return try decoder.row.getValue(forField: key.stringValue) as String
    }
    
    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        if T.self is Data.Type {
            // Bug: The compiler chooses NOT to use "decode() -> Data". We have to implement it in decode<T>()
            return try decoder.row.getValue(forField: key.stringValue) as Data as! T
        }
        if T.self is Date.Type {
            return try decoder.row.getValue(forField: key.stringValue) as Date as! T
        }
        guard let columnValue = decoder.row.columnMap[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: ""))
        }
        let d = SQLStringDecoder(sqlString: try columnValue.string())
        return try T(from: d)
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> {
        throw QueryError.initializationErrorMessage(message: "KeyedDecodingContainer nestedContainer not implemented")
    }
    
    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        throw QueryError.initializationErrorMessage(message: "KeyedDecodingContainer nestedContainer not implemented")
    }
    
    func superDecoder() throws -> Decoder {
        throw QueryError.initializationErrorMessage(message: "KeyedDecodingContainer superDecoder not implemented")
    }
    
    func superDecoder(forKey key: K) throws -> Decoder {
        throw QueryError.initializationErrorMessage(message: "KeyedDecodingContainer superDecoder(forKey) not implemented")
    }
}
