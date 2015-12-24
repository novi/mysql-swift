//
//  Database.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import CMySQL
import CoreFoundation

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
    
    public struct TimeZone {
        let timeZone: CFTimeZoneRef
        public init(name: String) {
            self.timeZone = CFTimeZoneCreateWithName(nil, name, true)
        }
        public init(GMTOffset: Int) {
            self.timeZone = CFTimeZoneCreateWithTimeIntervalFromGMT(nil, Double(GMTOffset))
        }
    }
    
    public struct Options {
        public let host: String
        public let port: Int
        public let userName: String
        public let password: String
        public let database: String
        public let timeZone: TimeZone
        public init(host: String, port: Int, userName: String, password: String, database: String, timeZone: TimeZone = TimeZone(GMTOffset: 0)) {
            self.host = host
            self.port = port
            self.userName = userName
            self.password = password
            self.database = database
            self.timeZone = timeZone
        }
    }
}

extension Connection {
    public enum Error: ErrorType {
        case GenericError(String)
        case ConnectionFailed(String)
        case ConnectionGetError
    }
}

final public class Connection {
    
    var isInTransaction: Int = 0
    var isInUse: Bool = false
    var mysql_: UnsafeMutablePointer<MYSQL>
    
    let pool: ConnectionPool
    public let options: Connection.Options
    
    init(options: Connection.Options, pool: ConnectionPool) {
        self.options = options
        self.pool = pool
        self.mysql_ = nil
    }
    
    public func release() {
        pool.releaseConnection(self)
    }
    
    func connect() throws {
        dispose()
        
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
        if isConnected == true {
            return mysql_
        }
        if isConnected == true && ping == true {
            return mysql_
        }
        try connect()
        return mysql_
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
    
    var ping: Bool {
        guard let mysql = mysql else {
            return false
        }
        return mysql_ping(mysql) == 0
    }
    
    func dispose() {
        guard let mysql = mysql else {
            return
        }
        mysql_close(mysql)
        self.mysql_ = nil
    }
    
    deinit {
        dispose()
    }
}

