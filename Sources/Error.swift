//
//  Error.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public enum QueryError: ErrorType {
    
    case QueryExecutionError(message: String, query: String)
    case ResultFetchError(message: String, query: String)
    case ResultNoField(query: String)
    case ResultFieldFetchError(query: String)
    case ResultParseError(message: String, result: String)
    
    case FieldIndexOutOfBounds(fieldCount: Int, attemped: Int, fieldName: String)
    case CastError(actual: String, expected: String, key: String)
    case MissingKeyError(key: String)
    
    case QueryParameterCountMismatch(query: String)
    case QueryParameterIdTypeError(query: String)
    
    case InvalidSQLDate(String)
}