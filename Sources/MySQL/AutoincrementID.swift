//
//  AutoincrementID.swift
//  MySQL
//
//  Created by Yusuke Ito on 6/27/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public enum AutoincrementID<I: IDType> {
    case noID
    case ID(I)

    public var id: I {
        switch self {
        case .noID: fatalError("has no ID")
        case .ID(let id): return id
        }
    }
    
    public mutating func replaceWith(id: I) {
        self = .ID(id)
    }
}

extension AutoincrementID: Equatable {
    
}

public func ==<I>(lhs: AutoincrementID<I>, rhs: AutoincrementID<I>) -> Bool {
    switch (lhs, rhs) {
    case (.noID, .noID): return true
    case (.ID(let lhs), .ID(let rhs) ): return lhs.id == rhs.id
    default: return false
    }
}

extension AutoincrementID: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noID: return "noID"
        case .ID(let id): return "\(id.id)"
        }
    }
}


extension AutoincrementID: SQLRawStringDecodable {
    public static func fromSQLValue(string: String) throws -> AutoincrementID<I> {
        return AutoincrementID(try I.fromSQLValue(string: string))
    }
    public init(_ id: I) {
        self = .ID(id)
    }
}

extension AutoincrementID: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        switch self {
        case .noID: return ""
        case .ID(let id): return try id.queryParameter(option: option)
        }
    }
    public var omitOnQueryParameter: Bool {
        switch self {
        case .noID: return true
        case .ID: return false
        }
    }
}



/// MARK: Codable support

extension AutoincrementID: Codable {
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .noID:
            break // nothing to encode
        case .ID(let id):
            try id.encode(to: encoder)
        }
    }
    
    public init(from decoder: Decoder) throws {
        self = .ID(try I.init(from: decoder))
    }
}

