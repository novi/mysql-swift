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
    internal static func getMySQLError(_ mysql: UnsafeMutablePointer<MYSQL>) -> String {
        guard let strPtr = mysql_error(mysql) else {
            return "unknown error. could not get error with `mysql_error()`."
        }
        guard let errorString = String(validatingUTF8: strPtr) else {
            return "unknown error. could not get error as string."
        }
        return errorString
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
    var sslMode: Connection.SSLMode { get }
}

fileprivate let defaultTimeZone = TimeZone(identifier: "UTC")!

public extension ConnectionOption {
    // Provide default options
    var timeZone: TimeZone {
        return defaultTimeZone
    }
    var encoding: Connection.Encoding {
        return .UTF8MB4
    }
    var timeout: Int {
        return 10
    }
    var reconnect: Bool {
        return true
    }
    var omitDetailsOnError: Bool {
        return true
    }
    var sslMode: Connection.SSLMode {
        return .preferred
    }
}

extension Connection {
    public enum Encoding: String {
        case UTF8 = "utf8"
        case UTF8MB4 = "utf8mb4"
    }
    
    public enum SSLMode {
        case disabled
        case preferred
    }
}

public enum ConnectionError: Error {
    case connectionError(String)
    case connectionPoolGetConnectionTimeoutError
}

public final class Connection {
    
    internal var isInUse: Bool = false
    private var mysql_: UnsafeMutablePointer<MYSQL>?
    
    internal let pool: ConnectionPool
    public let option: ConnectionOption
    
    internal init(option: ConnectionOption, pool: ConnectionPool) {
        self.option = option
        self.pool = pool
        self.mysql_ = nil
    }
    
    internal func release() {
        pool.releaseConnection(self)
    }
    
    internal static func setReconnect(_ reconnect: Bool, mysql: UnsafeMutablePointer<MYSQL>) {
        let reconnectPtr = UnsafeMutablePointer<my_bool>.allocate(capacity: 1)
        reconnectPtr.pointee = reconnect == false ? 0 : 1
        mysql_options(mysql, MYSQL_OPT_RECONNECT, reconnectPtr)
        reconnectPtr.deallocate()
    }
    
    func setReconnect(_ reconnect: Bool) {
        if let mysql = mysql {
            Connection.setReconnect(reconnect, mysql: mysql)
        }
    }
    
    internal func connect() throws -> UnsafeMutablePointer<MYSQL> {
        dispose()
        
        guard let mysql = mysql_init(nil) else {
            fatalError("mysql_init() failed.")
        }
        
        do {
            let timeoutPtr = UnsafeMutablePointer<UInt>.allocate(capacity: 1)
            timeoutPtr.pointee = UInt(option.timeout)
            mysql_options(mysql, MYSQL_OPT_CONNECT_TIMEOUT, timeoutPtr)
            timeoutPtr.deallocate()
        }
        
        switch option.sslMode {
        case .disabled:
            mysql_swift_set_ssl_option_disabled(mysql)
        case .preferred:
            mysql_swift_set_ssl_option_preferred(mysql)
        }
        
        Connection.setReconnect(option.reconnect, mysql: mysql)
        
        if mysql_real_connect(mysql,
            option.host,
            option.user,
            option.password,
            option.database,
            UInt32(option.port), nil, 0) == nil {
            // error
                throw ConnectionError.connectionError(MySQLUtil.getMySQLError(mysql))
        }
        mysql_set_character_set(mysql, option.encoding.rawValue)
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
    
    internal func ping() -> Bool {
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


