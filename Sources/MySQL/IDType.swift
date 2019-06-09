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
    #if swift(>=4.2)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    #else
    var hashValue: Int {
        return id.hashValue
    }
    #endif
}

extension IDType where Self: SQLRawStringDecodable, Self.T: SQLRawStringDecodable {
    static func fromSQLValue(string: String) throws -> Self {
        return Self(try T.fromSQLValue(string: string))
    }
}

extension IDType {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: Codable type
extension IDType {
    
    public init(from decoder: Decoder) throws {
        if T.self == Int.self {
            self.init(try decoder.singleValueContainer().decode(Int.self) as! T)
        } else if T.self == Int64.self {
            self.init(try decoder.singleValueContainer().decode(Int64.self) as! T)
        } else if T.self == UInt.self {
            self.init(try decoder.singleValueContainer().decode(UInt.self) as! T)
        } else if T.self == UInt64.self {
            self.init(try decoder.singleValueContainer().decode(UInt64.self) as! T)
        } else if T.self == String.self {
            self.init(try decoder.singleValueContainer().decode(String.self) as! T)
        } else {
            fatalError("`init(from:)` of \(Self.self) is not implemented")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        if T.self == Int.self {
            var container = encoder.singleValueContainer()
            try container.encode(id as! Int)
        } else if T.self == Int64.self {
            var container = encoder.singleValueContainer()
            try container.encode(id as! Int64)
        } else if T.self == UInt.self {
            var container = encoder.singleValueContainer()
            try container.encode(id as! UInt)
        } else if T.self == UInt64.self {
            var container = encoder.singleValueContainer()
            try container.encode(id as! UInt64)
        } else if T.self == String.self {
            var container = encoder.singleValueContainer()
            try container.encode(id as! String)
        } else {
            fatalError("`encode(to:)` of \(Self.self) is not implemented")
        }
    }
}

// TODO: this implementation does not work in release build, Swift 4.1
/*
extension IDType {
    
    public init(from decoder: Decoder) throws {
        fatalError("`init(from:)` of \(Self.self) is not implemented")
    }
    
    public func encode(to encoder: Encoder) throws {
        fatalError("`encode(to:)` of \(Self.self) is not implemented")
    }
}


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

extension IDType where T == String {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(String.self))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
}
 */
