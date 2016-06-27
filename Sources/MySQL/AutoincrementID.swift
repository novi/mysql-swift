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

extension AutoincrementID: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noID: return "noID"
        case .ID(let id): return id.id.description
        }
    }
}


extension AutoincrementID: SQLStringDecodable {
    public static func from(string: String) -> AutoincrementID<I>? {
        guard let id = I.from(string: string) else {
            return nil
        }
        return AutoincrementID(id)
    }
    public init(_ id: I) {
        self = .ID(id)
    }
}

extension AutoincrementID: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        switch self {
        case .noID: fatalError("TODO")
        case .ID(let id): return try id.queryParameter(option: option)
        }
    }
}
