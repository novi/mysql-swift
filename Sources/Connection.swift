//
//  Database.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import CMySQL

struct MySQLUtil {
    static func getMySQLErrorString(mysql: UnsafeMutablePointer<MYSQL>) -> String {
        let ch = mysql_error(mysql)
        if ch == nil {
            return "generic error"
        }
        guard let str = String.fromCString(ch) else {
            return "generic error"
        }
        return str as String
    }
}



extension Connection {
    public struct Options {
        public let host: String
        public let port: Int
        public let userName: String
        public let password: String
        public let database: String
        public let timeZone: Int // GMT Offset
        public init(host: String, port: Int, userName: String, password: String, database: String, timeZone: Int = 0) {
            self.host = host
            self.port = port
            self.userName = userName
            self.password = password
            self.database = database
            self.timeZone = timeZone
        }
    }
}

public class Connection {
    
    
    var mysql_: UnsafeMutablePointer<MYSQL>
    let options: Connection.Options
    
    public init(options: Connection.Options) {
        self.options = options
        self.mysql_ = nil
    }
    
    public enum Error: ErrorType {
        case GenericError(String)
        case ConnectionFailed(String)
    }
    
    public func connect() throws {
        disconnect()
        
        let mysql = mysql_init(nil)
        if mysql_real_connect(mysql,
            self.options.host,
            self.options.userName,
            self.options.password,
            self.options.database,
            UInt32(self.options.port), nil, 0) == nil {
            // error
                throw Error.ConnectionFailed(MySQLUtil.getMySQLErrorString(mysql))
        }
        mysql_set_character_set(mysql, "utf8")
        self.mysql_ = mysql
    }
    
    func connectIfNeeded() throws -> UnsafeMutablePointer<MYSQL> {
        if isConnected == false {
            try connect()
            return mysql_
        } else {
            return mysql_
        }
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
    
    func disconnect() {
        guard let mysql = mysql else {
            return
        }
        mysql_close(mysql)
        self.mysql_ = nil
    }
    
    deinit {
        disconnect()
    }
}

