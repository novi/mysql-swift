//
//  QueryParameterType.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/28/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import SQLFormatter
import Foundation

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
    func queryParameter() throws -> QueryParameterDictionary
}

public extension QueryParameterDictionaryType {
    func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return try queryParameter().queryParameter(option: option)
    }
}

public protocol QueryParameterOption {
    var timeZone: TimeZone { get }
}

internal struct QueryParameterNull: QueryParameter {
    
    private init() {
    }
    
    static let null = QueryParameterNull()
    
    func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( "NULL" )
    }
}

@available(*, renamed: "QueryParameterDictionary")
typealias QueryDictionary = QueryParameterDictionary

public struct QueryParameterDictionary: QueryParameter {
    private let dict: [String: QueryParameter?]
    public init(_ dict: [String: QueryParameter?]) {
        self.dict = dict
    }
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        var keyVals: [String] = []
        for (k, v) in dict {
            if v == nil || v?.omitOnQueryParameter == false {
                keyVals.append("\(SQLString.escapeForID(string: k)) = \(try (v ?? QueryParameterNull.null).queryParameter(option: option).escaped())")
            }
        }
        return EscapedQueryParameter( keyVals.joined(separator:  ", ") )
    }
}

fileprivate protocol QueryParameterArrayType: QueryParameter {
    
}

@available(*, renamed: "QueryParameterArray")
typealias QueryArray = QueryParameterArray

public struct QueryParameterArray: QueryParameter, QueryParameterArrayType {
    private let arr: [QueryParameter?]
    public init(_ arr: [QueryParameter?]) {
        self.arr = arr
    }
    public init(_ arr: [QueryParameter]) {
        self.arr = arr.map { Optional($0) }
    }
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return EscapedQueryParameter( try arr.filter({ val in
            if let valid = val {
                return valid.omitOnQueryParameter == false
            }
            return true
        }).map({
            if let val = $0 as? QueryParameterArrayType {
                return "(" + (try val.queryParameter(option: option).escaped()) + ")"
            }
            return try ($0 ?? QueryParameterNull.null).queryParameter(option: option).escaped()
        }).joined(separator: ", ") )
    }
}

extension Optional: QueryParameter where Wrapped: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        switch self {
        case .none:
            return QueryParameterNull.null.queryParameter(option: option)
        case .some(let value):
            return try value.queryParameter(option: option)
        }
    }
    public var omitOnQueryParameter: Bool {
        switch self {
        case .none:
            return false
        case .some(let value):
            return value.omitOnQueryParameter
        }
    }
}

internal struct EscapedQueryParameter: QueryParameterType {
    private let value: String
    private let idParameter: String?
    init(_ val: String, idParameter: String? = nil) {
        self.value = val
        self.idParameter = idParameter
    }
    func escaped() -> String {
        return value
    }
    func escapedForID() -> String? {
        return idParameter
    }
}

extension String: QueryParameterType {
    public func escaped() -> String {
        return SQLString.escape(string: self)
    }
    public func escapedForID() -> String? {
        return SQLString.escapeForID(string: self)
    }
}

extension String: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return self
    }
}

extension Int: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension UInt: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension Int64: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension Int32: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension Int16: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension Int8: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension UInt64: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension UInt32: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension UInt16: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension UInt8: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension Double: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension Float: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(self) )
    }
}

extension Bool: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( self ? "true" : "false" )
    }
}

extension Decimal: QueryParameter {
    public func queryParameter(option: QueryParameterOption) -> QueryParameterType {
        return EscapedQueryParameter( String(describing: self) )
    }
}

/// MARK: Codable support

fileprivate final class QueryParameterEncoder: Encoder {
    let codingPath = [CodingKey]()
    
    let userInfo = [CodingUserInfoKey : Any]()
    
    var dict: [String: QueryParameter?] = [:]
    var singleValue: QueryParameter? = nil
    enum StorageType {
        case single
        case dictionary
    }
    
    var storageType: StorageType = .dictionary
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(QueryParameterKeyedEncodingContainer<Key>(encoder: self))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("not supported unkeyedContainer in QueryParameter")
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        self.storageType = .single
        return QueryParameterSingleValueEncodingContainer(encoder: self)
    }
    
}


fileprivate struct QueryParameterSingleValueEncodingContainer: SingleValueEncodingContainer {
    let codingPath = [CodingKey]()
    
    var encoder: QueryParameterEncoder
    
    mutating func encodeNil() throws {
        encoder.singleValue = nil
    }
    
    mutating func encode(_ value: Bool) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: Int) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: Int8) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: Int16) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: Int32) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: Int64) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: UInt) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: UInt8) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: UInt16) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: UInt32) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: UInt64) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: Float) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: Double) throws {
        encoder.singleValue = value
    }
    
    mutating func encode(_ value: String) throws {
        encoder.singleValue = value
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        fatalError()
    }
    
    
}

fileprivate struct QueryParameterKeyedEncodingContainer<Key : CodingKey> : KeyedEncodingContainerProtocol {
    fileprivate let codingPath = [CodingKey]()
    
    fileprivate let encoder: QueryParameterEncoder
    
    mutating func encodeNil(forKey key: Key) throws {
        encoder.dict[key.stringValue] = nil
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        encoder.dict[key.stringValue] = value
    }
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if T.self == Date.self {
            encoder.dict[key.stringValue] = value as! Date
        } else if T.self == Data.self {
            encoder.dict[key.stringValue] = value as! Data
        } else if T.self == URL.self {
            // encode absoluteString same as JSONEncoder
            // https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/JSONEncoder.swift
            encoder.dict[key.stringValue] = (value as! URL).absoluteString
        } else if T.self == Decimal.self {
            encoder.dict[key.stringValue] = (value as! Decimal).description
        } else if let custom = value as? QueryCustomDataParameter {
            if let param = value as? QueryParameter {
                if !param.omitOnQueryParameter {
                    let data = try custom.encodeForQueryParameter()
                    encoder.dict[key.stringValue] = Blob(data: data, dataType: custom.queryParameterDataType)
                }
            } else {
                let data = try custom.encodeForQueryParameter()
                encoder.dict[key.stringValue] = Blob(data: data, dataType: custom.queryParameterDataType)
            }
        } else {
            let singleValueEncoder = QueryParameterEncoder()
            try value.encode(to: singleValueEncoder)
            if let param = value as? QueryParameter {
                if !param.omitOnQueryParameter {
                    encoder.dict[key.stringValue] = singleValueEncoder.singleValue
                }
            } else {
                encoder.dict[key.stringValue] = singleValueEncoder.singleValue
            }
        }
        
        //fatalError("not supported type \(T.self)")
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("nestedContainer in query parameter is not supported.")
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError("nestedUnkeyedContainer in query parameter is not supported.")
    }
    
    mutating func superEncoder() -> Encoder {
        fatalError("superEncoder in query parameter is not supported.")
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        fatalError("superEncoder(forKey:) in query parameter is not supported.")
    }
}



extension Encodable where Self: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        let encoder = QueryParameterEncoder()
        try self.encode(to: encoder)
        switch encoder.storageType {
        case .dictionary:
            return try QueryParameterDictionary(encoder.dict).queryParameter(option: option)
        case .single:
            return try (encoder.singleValue ?? QueryParameterNull.null).queryParameter(option: option)
        }
    }
}
