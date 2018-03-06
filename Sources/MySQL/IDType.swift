//
//  IDType.swift
//  MySQL
//
//  Created by Yusuke Ito on 6/27/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public protocol IDType: QueryParameter, Hashable, Codable {
    associatedtype T: QueryParameter, Hashable, Codable
    var id: T { get }
    init(_ id: T)
}

public extension IDType {
    
    func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return try id.queryParameter(option: option)
    }
    var hashValue: Int {
        return id.hashValue
    }
}

extension IDType where Self: SQLRawStringDecodable, Self.T: SQLRawStringDecodable {
    static func fromSQLValue(string: String) throws -> Self {
        return Self(try T.fromSQLValue(string: string))
    }
}

public func ==<T: IDType>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}

// MARK: Codable type

extension IDType where T == Int {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(Int.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}

extension IDType where T == Int64 {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(Int64.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}

extension IDType where T == UInt {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(UInt.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}

extension IDType where T == UInt64 {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(UInt64.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}
