//
//  Error.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public enum QueryError: ErrorType {
    
    case QueryExecutionError(String)
    case ResultFetchError(String)
    case ResultNoField
    case ResultFieldFetchError
    case ValueError(String)
    
    case FieldIndexOutOfBounds(fieldCount: Int, attemped: Int)
    case CastError(actual: String, expected: String, key: String)
    case MissingKeyError(key: String)
    
    case QueryParameterCountMismatch
    case QueryParameterIdTypeError
    
    case InvalidSQLDate(String)
}