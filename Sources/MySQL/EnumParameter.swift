//
//  EnumParameter.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public protocol QueryEnumParameter: RawRepresentable, QueryParameter {
    
}

extension QueryEnumParameter where Self.RawValue: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return try rawValue.queryParameter(option: option)
    }
}
