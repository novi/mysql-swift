//
//  IDType.swift
//  MySQL
//
//  Created by Yusuke Ito on 6/27/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public protocol IDType: SQLStringDecodable, QueryParameter, Hashable {
    associatedtype T: SQLStringDecodable, Equatable, QueryParameter, Hashable, CustomStringConvertible
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
