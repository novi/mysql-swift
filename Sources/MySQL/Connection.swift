//
//  Database.swift
//  MySQL
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import CMySQL
import CoreFoundation
import Foundation

internal struct MySQLUtil {
    internal static func getMySQLError(_ mysqlPtr: UnsafeMutablePointer<MYSQL>?) -> String {
        guard let mysql = mysqlPtr else {
            return "generic error"
        }
        guard let ch = mysql_error(mysql) else {
            return "generic error"
        }
        guard let str = String(validatingUTF8: ch) else {
            return "generic error"
        }
        return str as String
    }
}


public protocol ConnectionOption {
    var host: String { get }
    var port: Int { get }
    var user: String { get }
    var password: String { get }
    var database: String { get }
    var timeZone: TimeZone { get }
    var encoding: Connection.Encoding { get }
    var timeout: Int { get }
    var reconnect: Bool { get }
    var omitDetailsOnError: Bool { get }
}

fileprivate let defaultTimeZone = TimeZone(identifier: "UTC")!

public extension ConnectionOption {
    // Provide default options
    var timeZone: TimeZone {
        return defaultTimeZone
    }
    var encoding: Connection.Encoding {
        return .UTF8
    }
    var timeout: Int {
        return 10
    }
    var reconnect: Bool {
        return false
    }
    var omitDetailsOnError: Bool {
        return false
    }
}

extension Connection {
    public enum Encoding: String {
        case UTF8 = "utf8"
        case UTF8MB4 = "utf8mb4"
    }
    
}

extension Connection {
    public enum Error: Swift.Error {
        case connectionError(String)
        case connectionPoolGetConnectionError
    }
}

public final class Connection {
    
    internal var isInUse: Bool = false
    private var mysql_: UnsafeMutablePointer<MYSQL>?
    
    internal let pool: ConnectionPool
    public let options: ConnectionOption
    
    init(options: ConnectionOption, pool: ConnectionPool) {
        self.options = options
        self.pool = pool
        self.mysql_ = nil
    }
    
    internal func release() {
        pool.releaseConnection(self)
    }
    
    internal func connect() throws -> UnsafeMutablePointer<MYSQL> {
        dispose()
        
        guard let mysql = mysql_init(nil) else {
            fatalError("mysql_init() failed.")
        }
        
        do {
            let timeoutPtr = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            timeoutPtr.pointee = options.timeout
            mysql_options(mysql, MYSQL_OPT_CONNECT_TIMEOUT, timeoutPtr)
            timeoutPtr.deallocate(capacity: 1)
        }
        
        do {
            let reconnectPtr = UnsafeMutablePointer<my_bool>.allocate(capacity: 1)
            reconnectPtr.pointee = options.reconnect == false ? 0 : 1
            mysql_options(mysql, MYSQL_OPT_RECONNECT, reconnectPtr)
            reconnectPtr.deallocate(capacity: 1)
        }
        
        if mysql_real_connect(mysql,
            options.host,
            options.user,
            options.password,
            options.database,
            UInt32(options.port), nil, 0) == nil {
            // error
                throw Error.connectionError(MySQLUtil.getMySQLError(mysql))
        }
        mysql_set_character_set(mysql, options.encoding.rawValue)
        self.mysql_ = mysql
        return mysql
    }
    
    internal func connectIfNeeded() throws -> UnsafeMutablePointer<MYSQL> {
        guard let mysql = self.mysql_ else {
            return try connect()
        }
        return mysql
    }
    
    private var mysql: UnsafeMutablePointer<MYSQL>? {
        guard mysql_ != nil else {
            return nil
        }
        return mysql_
    }
    
    internal var ping: Bool {
        _ = try? connectIfNeeded()
        guard let mysql = mysql else {
            return false
        }
        return mysql_ping(mysql) == 0
    }
    
    private func dispose() {
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


