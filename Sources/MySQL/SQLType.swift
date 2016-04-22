//
//  SQLType.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public protocol IDType: SQLStringDecodable, QueryParameter, Hashable {
    associatedtype T: SQLStringDecodable, Equatable, QueryParameter, Hashable
    var id: T { get }
    init(_ id: T)
}

public extension IDType {
    static func from(string: String) -> Self? {
        guard let val = T.from(string: string) else {
            return nil
        }
        return Self(val)
    }
    func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return try id.queryParameter(option: option)
    }
    var hashValue: Int {
        return id.hashValue
    }
}

public func ==<T: IDType>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}


public protocol SQLEnumType: SQLStringDecodable, RawRepresentable, QueryParameter {
    
}

extension SQLEnumType where RawValue == String {
    public static func from(string: String) -> Self? {
        return Self.init(rawValue: string)
    }
}

extension SQLEnumType where RawValue == String {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return rawValue.queryParameter(option: option)
    }
}