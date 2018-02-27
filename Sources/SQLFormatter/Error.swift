//
//  Error.swift
//  SQLFormatter
//
//  Created by Yusuke Ito on 4/5/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

public enum QueryFormatError: Error {
    case parameterCountMismatch(query: String)
    case parameterIDTypeError(givenValue: String, query: String)
}
