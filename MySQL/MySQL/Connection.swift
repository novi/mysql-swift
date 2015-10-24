//
//  Connection.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import Foundation
import Himotoki
import MySQLConnector

public class Connection {
    
    public struct Status {
        let affectedRows: Int
        let insertedId: Int
        init(mysql: UnsafeMutablePointer<MYSQL>) {
            self.insertedId = Int(mysql_insert_id(mysql))
            self.affectedRows = Int(mysql_affected_rows(mysql))
        }
    }
    
    public enum QueryError: ErrorType {
        case NotConnected
        case QueryError(String)
        case ResultFetchError(String)
        case NoField
        case FieldFetchError
        case ValueError(String)
    }
    
    struct Field {
        let name: String
        let type: enum_field_types
        init?(f: MYSQL_FIELD) {
            if f.name == nil {
                return nil
            }
            guard let fs = NSString(UTF8String: f.name) else {
                return nil
            }
            self.name = fs as String
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
    
    public func query<T: Decodable where T.DecodedType == T>(query: String, args:[AnyObject]) throws -> [T] {
        guard let mysql = self.mysql where isConnected else {
            throw QueryError.NotConnected
        }
        
        guard mysql_query(mysql, (query as NSString).UTF8String) == 0 else {
            throw QueryError.QueryError(MySQLUtil.getMySQLErrorString(mysql))
        }
        let res = mysql_use_result(mysql)
        guard res != nil else {
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
                    //cols[name] = nil
                } else {
                    if let str = NSString(UTF8String: sf) {
                        cols[f.name] = try f.castValue(str as String, row: rowCount)
                    } else {
                        throw QueryError.ValueError("parse value int \(f.name), row: \(rowCount)")
                    }
                }
                
            }
            rowCount++
            rows.append(cols)
        }
        
        return try decodeArray(rows)
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