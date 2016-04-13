//
//  Error.swift
//  SQLFormatter
//
//  Created by Yusuke Ito on 4/5/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

public enum QueryFormatError: ErrorProtocol {
    case CastError(actual: String, expected: String, key: String)
    case QueryParameterCountMismatch(query: String)
    case QueryParameterIdTypeError(query: String)
}
