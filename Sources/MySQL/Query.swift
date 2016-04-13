//
//  Connection.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import CMySQL
import SQLFormatter

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

extension String {
    func subString(max max: Int) -> String {
        return self[startIndex..<startIndex.advanced(by: max, limit: endIndex)]
    }
}

extension Connection {
    
    struct NullValue {
        static let null = NullValue()
    }
    
    struct EmptyRowResult: QueryRowResultType {
        static func decodeRow(r: QueryRowResult) throws -> EmptyRowResult {
            return EmptyRowResult()
        }
    }
    
    struct Field {
        let name: String
        let type: enum_field_types
        let isBinary: Bool
        init?(f: MYSQL_FIELD) {
            if f.name == nil {
                return nil
            }
            guard let fs = String(validatingUTF8: f.name) else {
                return nil
            }
            self.name = fs
            self.type = f.type
            self.isBinary = f.flags & UInt32(BINARY_FLAG) > 0 ? true : false
        }
        func castValue(str: String, row: Int, timeZone: TimeZone) throws -> Any {
            if type == MYSQL_TYPE_DATE ||
                type == MYSQL_TYPE_DATETIME ||
                type == MYSQL_TYPE_TIME ||
                type == MYSQL_TYPE_TIMESTAMP
                
                //type == MYSQL_TYPE_TIME2 ||
                //type == MYSQL_TYPE_DATETIME2 ||
                //type == MYSQL_TYPE_TIMESTAMP2
                
            {
                return try SQLDate(sqlDate: str, timeZone: timeZone)
            }
            if isBinary && (
                type == MYSQL_TYPE_BLOB ||
                    type == MYSQL_TYPE_BIT
                ) {
                throw QueryError.ResultParseError(message: "blob type is not supported at row:\(row)", result: str)
            }
            return str
        }
    }
    
    public func query<T: QueryRowResultType>(query formattedQuery: String) throws -> ([T], QueryStatus) {
        let mysql = try connectIfNeeded()
        
        func queryPrefix() -> String {
            if options.omitDetailsOnError {
                return ""
            }
            return formattedQuery.subString(max: 1000)
        }
        
        guard mysql_real_query(mysql, formattedQuery, UInt(formattedQuery.utf8.count)) == 0 else {
            throw QueryError.QueryExecutionError(message: MySQLUtil.getMySQLErrorString(mysql), query: queryPrefix())
        }
        let status = QueryStatus(mysql: mysql)
        
        let res = mysql_use_result(mysql)
        guard res != nil else {
            if mysql_field_count(mysql) == 0 {
                // actual no result
                return ([], status)
            }
            throw QueryError.ResultFetchError(message: MySQLUtil.getMySQLErrorString(mysql), query: queryPrefix())
        }
        defer {
            mysql_free_result(res)
        }
        
        let fieldCount = Int(mysql_num_fields(res))
        guard fieldCount > 0 else {
            throw QueryError.ResultNoField(query: queryPrefix())
        }
        
        // fetch field info
        let fieldDef = mysql_fetch_fields(res)
        guard fieldDef != nil else {
            throw QueryError.ResultFieldFetchError(query: queryPrefix())
        }
        var fields:[Field] = []
        for i in 0..<fieldCount {
            guard let f = Field(f: fieldDef[i]) else {
                throw QueryError.ResultFieldFetchError(query: queryPrefix())
            }
            fields.append(f)
        }
        
        // fetch rows
        var rows:[QueryRowResult] = []
        
        var rowCount: Int = 0
        while true {
            let row = mysql_fetch_row(res)
            if row == nil {
                break
            }
            var cols:[Any] = []
            for i in 0..<fieldCount {
                let sf = row[i]
                let f = fields[i]
                if sf == nil {
                    cols.append(NullValue.null)
                } else {
                    if let str = String(validatingUTF8: sf) {
                        cols.append(try f.castValue(str, row: rowCount, timeZone: options.timeZone))
                    } else {
                        throw QueryError.ResultParseError(message: "in \(f.name), at row: \(rowCount)", result: "")
                    }
                }
                
            }
            rowCount += 1
            if fields.count != cols.count {
                throw QueryError.ResultParseError(message: "invalid fetched column count", result: "")
            }
            rows.append(QueryRowResult(fields: fields, cols: cols))
        }
        
        return try (rows.map({ try T.decodeRow($0) }), status)
    }
}

public struct QueryParameterOption: QueryParameterOptionType {
    let timeZone: Connection.TimeZone
}


extension Connection {
    
    static func buildArgs(args: [QueryParameter], option: QueryParameterOption) throws -> [QueryParameterType] {
        return try args.map { arg in
            if let val = arg as? String {
                return val
            }
            return try arg.queryParameter(option: option)
        }
    }
    
    public func query<T: QueryRowResultType>(query: String, _ args: [QueryParameter] = []) throws -> ([T], QueryStatus) {
        let option = QueryParameterOption(
            timeZone: options.timeZone
        )
        let queryString = try QueryFormatter.format(query, args: self.dynamicType.buildArgs(args, option: option))
        return try self.query(query: queryString)
    }
    
    public func query<T: QueryRowResultType>(query: String, _ args: [QueryParameter] = []) throws -> [T] {
        let (rows, _) = try self.query(query, args) as ([T], QueryStatus)
        return rows
    }
    
    public func query(query: String, _ args: [QueryParameter] = []) throws -> QueryStatus {
        let (_, status) = try self.query(query, args) as ([EmptyRowResult], QueryStatus)
        return status
    }
}