//
//  RawRepresentableParameter.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/21/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter
import Foundation


public protocol QueryRawRepresentableParameter: RawRepresentable, QueryParameter {
    
}


extension QueryRawRepresentableParameter where RawValue: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return try rawValue.queryParameter(option: option)
    }
}

/*
extension RawRepresentable where RawValue: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return try rawValue.queryParameter(option: option)
    }
}*/

