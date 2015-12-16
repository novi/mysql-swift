//
//  Connection.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import CMySQL

public struct QueryStatus: CustomStringConvertible {
    public let affectedRows: Int
    public let insertedId: Int
    init(mysql: UnsafeMutablePointer<MYSQL>) {
        self.insertedId = Int(mysql_insert_id(mysql))
        let arows = mysql_affected_rows(mysql)
        if arows == (~0) {
            self.affectedRows = 0 // error or select statement
        } else {
            self.affectedRows = Int(arows)
        }
    }
    public var description: String {
        return "inserted id = \(insertedId), affected rows = \(affectedRows)"
    }
}


extension Connection {
    
    struct NullValue {
        static let null = NullValue()
    }
    
    struct EmptyRowResult: QueryResultRowType {
        static func decodeRow(r: QueryResult) throws -> EmptyRowResult {
            return EmptyRowResult()
        }
    }
    
    struct Field {
        let name: String
        let type: enum_field_types
        init?(f: MYSQL_FIELD) {
            if f.name == nil {
                return nil
            }
            guard let fs = String.fromCString(f.name) else {
                return nil
            }
            self.name = fs
            self.type = f.type
        }
        func castValue(str: String, row: Int) throws -> Any {
            if type == MYSQL_TYPE_TINY ||
                type == MYSQL_TYPE_SHORT ||
                type == MYSQL_TYPE_LONG ||
                type == MYSQL_TYPE_INT24 {
                    guard let v = Int(str) else {
                        throw QueryError.ValueError("parse error: \(str) as \(self.type) in \(self.name) at \(row)")
                    }
                    return v
            }
            if type == MYSQL_TYPE_FLOAT ||
                type == MYSQL_TYPE_DECIMAL ||
                type == MYSQL_TYPE_NEWDECIMAL {
                guard let v = Float(str) else {
                    throw QueryError.ValueError("parse error: \(str) as \(self.type) in \(self.name) at \(row)")
                }
                return v
            }
            if type == MYSQL_TYPE_DOUBLE {
                guard let v = Double(str) else {
                    throw QueryError.ValueError("parse error: \(str) as \(self.type) in \(self.name) at \(row)")
                }
                return v
            }
            if type == MYSQL_TYPE_DATE ||
                type == MYSQL_TYPE_DATETIME ||
                type == MYSQL_TYPE_DATETIME2 ||
                type == MYSQL_TYPE_TIME ||
                type == MYSQL_TYPE_TIME2 ||
                type == MYSQL_TYPE_TIMESTAMP ||
                type == MYSQL_TYPE_TIMESTAMP2 {
                return try SQLDate(sqlDate: str, timeZoneOffset: 0) // TODO: timezone
            }
            return str
        }
    }
    
    public func query<T: QueryResultRowType>(query formattedQuery: String) throws -> ([T], QueryStatus) {
        let mysql = try connectIfNeeded()
    
        print("query: \(formattedQuery)")
        guard mysql_real_query(mysql, formattedQuery, UInt(formattedQuery.utf8.count)) == 0 else {
            throw QueryError.QueryExecutionError(MySQLUtil.getMySQLErrorString(mysql))
        }
        let status = QueryStatus(mysql: mysql)
        
        let res = mysql_use_result(mysql)
        guard res != nil else {
            if mysql_field_count(mysql) == 0 {
                // actual no result
                return ([], status)
            }
            throw QueryError.ResultFetchError(MySQLUtil.getMySQLErrorString(mysql))
        }
        defer {
            mysql_free_result(res)
        }
        
        let fieldCount = Int(mysql_num_fields(res))
        guard fieldCount > 0 else {
            throw QueryError.ResultNoField
        }
        
        // fetch field info
        let fieldDef = mysql_fetch_fields(res)
        guard fieldDef != nil else {
            throw QueryError.ResultFieldFetchError
        }
        var fields:[Field] = []
        for i in 0..<fieldCount {
            guard let f = Field(f: fieldDef[i]) else {
                throw QueryError.ResultFieldFetchError
            }
            fields.append(f)
        }
        
        // fetch rows
        var rows:[[String:Any]] = []
        
        var rowCount: Int = 0
        while true {
            let row = mysql_fetch_row(res)
            if row == nil {
                break
            }
            var cols:[String:Any] = [:]
            for i in 0..<fieldCount {
                let sf = row[i]
                let f = fields[i]
                if sf == nil {
                    cols[f.name] = NullValue.null
                } else {
                    if let str = String.fromCString(sf) {
                        cols[f.name] = try f.castValue(str, row: rowCount)
                    } else {
                        throw QueryError.ValueError("parse string value in \(f.name), at row: \(rowCount)")
                    }
                }
                
            }
            rowCount++
            rows.append(cols)
        }
        
        return try (rows.map({ try T.decodeRow(QueryResult(row: $0 )) }), status)
    }
}