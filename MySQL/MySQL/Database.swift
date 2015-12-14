//
//  Database.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import MySQLConnector

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

public class Database {
    
    public struct ConnectionInfo {
        public let host: String
        public let port: Int
        public let userName: String
        public let password: String
        public let database: String
        public init(host: String, port: Int, userName: String, password: String, database: String) {
            self.host = host
            self.port = port
            self.userName = userName
            self.password = password
            self.database = database
        }
    }
    
    let connectionInfo: ConnectionInfo
    public init(info: ConnectionInfo) {
        self.connectionInfo = info
    }
    
    public enum Error: ErrorType {
        case GenericError(String)
        case ConnectionFailed(String)
        case NoDatabase(String)
    }
    
    public func getConnection() throws -> Connection {
        let mysql = mysql_init(nil)
        if mysql_real_connect(mysql,
            self.connectionInfo.host,
            self.connectionInfo.userName,
            self.connectionInfo.password,
            self.connectionInfo.database,
            UInt32(self.connectionInfo.port), nil, 0) == nil {
            // error
                throw Error.ConnectionFailed(MySQLUtil.getMySQLErrorString(mysql))
        }
        mysql_set_character_set(mysql, "utf8")
        return Connection(mysql: mysql)
    }
}

