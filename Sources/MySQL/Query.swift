//
//  Connection.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import CMySQL
import SQLFormatter
import Foundation

public struct QueryStatus: CustomStringConvertible {
    public let affectedRows: UInt64
    
    public let insertedID: UInt64
    
    @available(*, deprecated)
    public var insertedId: Int {
        return Int(insertedID)
    }
    
    init(mysql: UnsafeMutablePointer<MYSQL>) {
        self.insertedID = mysql_insert_id(mysql)
        let arows = mysql_affected_rows(mysql)
        if arows == (~0) {
            self.affectedRows = 0 // error or select statement
        } else {
            self.affectedRows = arows
        }
    }
    
    public var description: String {
        return "inserted id = \(insertedID), affected rows = \(affectedRows)"
    }
}

internal extension String {
    func subString(max: Int) -> String {
        guard let r = index(startIndex, offsetBy: max, limitedBy: endIndex) else {
            return self
        }
        return String(self[startIndex..<r])
    }
}

extension Connection {
    
    internal struct NullValue {
        static let null = NullValue()
    }
    
    internal struct EmptyRowResult: QueryRowResultType {
        static func decodeRow(r: QueryRowResult) throws -> EmptyRowResult {
            return EmptyRowResult()
        }
    }
    
    internal struct Field {
        let name: String
        let type: enum_field_types
        init?(f: MYSQL_FIELD) {
            if f.name == nil {
                return nil
            }
            guard let fs = String(validatingUTF8: f.name) else {
                return nil
            }
            self.name = fs
            self.type = f.type
        }
        var isDate: Bool {
            return type == MYSQL_TYPE_DATE ||
                type == MYSQL_TYPE_DATETIME ||
                type == MYSQL_TYPE_TIME ||
                type == MYSQL_TYPE_TIMESTAMP
        }
        
    }
    
    enum FieldValue {
        case null
        case binary(Data)
        case date(Date)
        
        static func makeBinary(ptr: UnsafeMutablePointer<Int8>, length: UInt) -> FieldValue {
            let data = Data(bytes: UnsafeRawPointer(ptr), count: Int(length))
            return FieldValue.binary(data)
        }
        
        func string() throws -> String {
            switch self {
            case .null:
                fatalError("TODO")
            case .date:
                fatalError("TODO")
            case .binary(let data):
                guard let string = String(data: data, encoding: .utf8) else {
                    throw QueryError.resultParseError(message: "invalid utf8 string bytes.", result: "")
                }
                return string
            }
        }
    }
    
    fileprivate func query<T: QueryRowResultType>(query formattedQuery: String) throws -> ([T], QueryStatus) {
        let mysql = try connectIfNeeded()
        
        func queryPrefix() -> String {
            if options.omitDetailsOnError {
                return ""
            }
            return formattedQuery.subString(max: 1000)
        }
        
        guard mysql_real_query(mysql, formattedQuery, UInt(formattedQuery.utf8.count)) == 0 else {
            throw QueryError.queryExecutionError(message: MySQLUtil.getMySQLError(mysql), query: queryPrefix())
        }
        let status = QueryStatus(mysql: mysql)
        
        let res = mysql_use_result(mysql)
        guard res != nil else {
            if mysql_field_count(mysql) == 0 {
                // actual no result
                return ([], status)
            }
            throw QueryError.resultFetchError(message: MySQLUtil.getMySQLError(mysql), query: queryPrefix())
        }
        defer {
            mysql_free_result(res)
        }
        
        let fieldCount = Int(mysql_num_fields(res))
        guard fieldCount > 0 else {
            throw QueryError.resultNoField(query: queryPrefix())
        }
        
        // fetch field info
        guard let fieldDef = mysql_fetch_fields(res) else {
            throw QueryError.resultFieldFetchError(query: queryPrefix())
        }
        var fields:[Field] = []
        for i in 0..<fieldCount {
            guard let f = Field(f: fieldDef[i]) else {
                throw QueryError.resultFieldFetchError(query: queryPrefix())
            }
            fields.append(f)
        }
        
        // fetch rows
        var rows:[QueryRowResult] = []
        
        var rowCount: Int = 0
        while true {
            guard let row = mysql_fetch_row(res) else {
                break // end of rows
            }
            
            guard let lengths = mysql_fetch_lengths(res) else {
                throw QueryError.resultRowFetchError(query: queryPrefix())
            }
            
            var cols:[FieldValue] = []
            for i in 0..<fieldCount {
                let field = fields[i]
                if let valf = row[i], row[i] != nil {
                    let binary = FieldValue.makeBinary(ptr: valf, length: lengths[i])
                    if field.isDate {
                        cols.append(FieldValue.date(try Date(sqlDate: binary.string(), timeZone: options.timeZone)))
                    } else {
                        cols.append(binary)
                    }                    
                } else {
                    cols.append(FieldValue.null)
                }
                
            }
            rowCount += 1
            if fields.count != cols.count {
                throw QueryError.resultParseError(message: "invalid fetched column count", result: "")
            }
            rows.append(QueryRowResult(fields: fields, cols: cols))
        }
        
        return try (rows.map({ try T.decodeRow(r: $0) }), status)
    }
}

public struct QueryParameterOption: QueryParameterOptionType {
    let timeZone: TimeZone
}


extension Connection {
    
    internal static func buildArgs(_ args: [QueryParameter], option: QueryParameterOption) throws -> [QueryParameterType] {
        return try args.map { arg in
            if let val = arg as? String {
                return val
            }
            return try arg.queryParameter(option: option)
        }
    }
    
    public func query<T: QueryRowResultType>(_ query: String, _ args: [QueryParameter] = []) throws -> ([T], QueryStatus) {
        let option = QueryParameterOption(
            timeZone: options.timeZone
        )
        let queryString = try QueryFormatter.format(query: query, args: type(of: self).buildArgs(args, option: option))
        return try self.query(query: queryString)
    }
    
    public func query<T: QueryRowResultType>(_ query: String, _ args: [QueryParameter] = []) throws -> [T] {
        let (rows, _) = try self.query(query, args) as ([T], QueryStatus)
        return rows
    }
    
    public func query(_ query: String, _ args: [QueryParameter] = []) throws -> QueryStatus {
        let (_, status) = try self.query(query, args) as ([EmptyRowResult], QueryStatus)
        return status
    }
}
