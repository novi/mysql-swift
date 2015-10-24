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
    }
    
    let mysql: UnsafeMutablePointer<MYSQL>
    init(mysql: UnsafeMutablePointer<MYSQL>) {
        self.mysql = mysql
    }
    
    var isConnected: Bool {
        return mysql_stat(mysql) != nil ? true : false
    }
    
    public func query(query: String, args:[AnyObject]) throws -> [[String?]] {
        guard isConnected else {
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
        
        var rows:[[String?]] = []
        
        while true {
            let row = mysql_fetch_row(res)
            if row == nil {
                break
            }
            var cols:[String?] = []
            for i in 0..<fieldCount {
                let sf = row[i]
                if sf == nil {
                    cols.append(nil)
                } else {
                    let str = NSString(UTF8String: sf) ?? ""
                    cols.append(str as String)
                }
                
            }
            rows.append(cols)
        }
        
        return rows
    }
    
    func disconnect() {
        mysql_close(mysql)
    }
    
    deinit {
        disconnect()
    }
}