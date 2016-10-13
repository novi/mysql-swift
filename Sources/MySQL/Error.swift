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
    case resultNoField(query: String)
    case resultRowFetchError(query: String)
    case resultFieldFetchError(query: String)
    case resultParseError(message: String, result: String)
    
    case fieldIndexOutOfBounds(fieldCount: Int, attemped: Int, fieldName: String)
    case castError(actual: String, expected: String, key: String)
    case missingKeyError(key: String)
    
    case invalidSQLDate(String)
}
