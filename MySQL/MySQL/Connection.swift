//
//  Connection.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import MySQLConnector

public class Connection {
    
    class NullValue: AnyObject {
        static let null = NullValue()
    }
    
    struct EmptyRowResult: QueryResultRowType {
        static func fromRow(r: QueryResult) throws -> EmptyRowResult {
            return EmptyRowResult()
        }
    }
    
    public struct Status: CustomStringConvertible {
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
        func castValue(str: String, row: Int) throws -> AnyObject {
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
            return str
        }
    }
    
    var mysql_: UnsafeMutablePointer<MYSQL>
    init(mysql: UnsafeMutablePointer<MYSQL>) {
        self.mysql_ = mysql
    }
    
    var mysql: UnsafeMutablePointer<MYSQL>? {
        guard mysql_ != nil else {
            return nil
        }
        return mysql_
    }
    
    var isConnected: Bool {
        guard let mysql = mysql else {
            return false
        }
        return mysql_stat(mysql) != nil ? true : false
    }
    
    public func query<T: QueryResultRowType>(query: String, _ args:[Any?] = []) throws -> [T] {
        let (rows, _) = try self.query(query, args) as ([T], Status)
        return rows
    }
    
    public func query(query: String, _ args:[Any?] = []) throws -> Status {
        let (_, status) = try self.query(query, args) as ([EmptyRowResult], Status)
        return status
    }
    
    public func query<T: QueryResultRowType>(query: String, _ args:[Any?] = []) throws -> ([T], Status) {
        guard let mysql = self.mysql where isConnected else {
            throw QueryError.NotConnected
        }
        
        let formatted = try SQLString.format(query, args: args)
        print("query: \(formatted)")
        guard mysql_query(mysql, formatted) == 0 else {
            throw QueryError.QueryError(MySQLUtil.getMySQLErrorString(mysql))
        }
        let status = Status(mysql: mysql)
        
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
            throw QueryError.NoField
        }
        
        // fetch field info
        let fieldDef = mysql_fetch_fields(res)
        guard fieldDef != nil else {
            throw QueryError.FieldFetchError
        }
        var fields:[Field] = []
        for i in 0..<fieldCount {
            guard let f = Field(f: fieldDef[i]) else {
                throw QueryError.FieldFetchError
            }
            fields.append(f)
        }
        
        // fetch rows
        var rows:[[String:AnyObject]] = []
        
        var rowCount: Int = 0
        while true {
            let row = mysql_fetch_row(res)
            if row == nil {
                break
            }
            var cols:[String:AnyObject] = [:]
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
        
        return try (rows.map({ try T.fromRow(QueryResult(row: $0 )) }), status)
    }
    
    func disconnect() {
        guard let mysql = mysql else {
            return
        }
        mysql_close(mysql)
        self.mysql_ = nil
    }
    
    deinit {
        disconnect()
        disconnect()
    }
}