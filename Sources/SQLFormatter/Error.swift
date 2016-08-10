//
//  Error.swift
//  SQLFormatter
//
//  Created by Yusuke Ito on 4/5/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

public enum QueryFormatError: Error {
    case castError(actual: String, expected: String, key: String)
    case queryParameterCountMismatch(query: String)
    case queryParameterIdTypeError(query: String)
}
