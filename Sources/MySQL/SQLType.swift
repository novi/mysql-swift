//
//  SQLType.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter


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