//
//  Error.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public enum QueryError: Error {
    
    case queryExecutionError(message: String, query: String)
    case resultFetchError(message: String, query: String)
    case resultNoFieldError(query: String)
    case resultRowFetchError(query: String)
    case resultFieldFetchError(query: String)
    case resultParseError(message: String, result: String)
    
    case resultCastError(actualValue: String, expectedType: String, forField: String)
    case resultDecodeError(rawSQLValue: String, forType: Any)
    case resultDecodeErrorMessage(message: String)
    case SQLDateStringError(String)
    case SQLRawStringDecodeError(error: Error, actualValue: String, expectedType: String, forField: String)
    
    case missingField(String)
}

public enum QueryParameterError: Error {
    case dateComponentsError(String)
}
