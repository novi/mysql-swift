//
//  IDType.swift
//  MySQL
//
//  Created by Yusuke Ito on 6/27/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public protocol IDType: SQLStringDecodable, QueryParameter, Hashable {
    associatedtype T: SQLStringDecodable, QueryParameter, Hashable
    var id: T { get }
    init(_ id: T)
}

public extension IDType {
    static func fromSQL(string: String) throws -> Self {
        return Self(try T.fromSQL(string: string))
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
