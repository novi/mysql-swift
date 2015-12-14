//
//  Error.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public enum QueryError: ErrorType {
    
    case NotConnected
    
    case QueryError(String)
    case ResultFetchError(String)
    case NoField
    case FieldFetchError
    case ValueError(String)
    
    case CastError(actual: String, expected: String, key: String)
    case MissingKeyError(key: String)
}