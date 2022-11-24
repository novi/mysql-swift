//
//  ConnectionPool.swift
//  MySQL
//
//  Created by ito on 12/24/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Dispatch
#if os(Linux)
    import Glibc
#endif
import CMySQL

fileprivate var LibraryInitialized: Atomic<Bool> = Atomic(false)

fileprivate func InitializeMySQLLibrary() {
    LibraryInitialized.syncWriting {
        guard $0 == false else {
            return
        }
        if mysql_server_init(0, nil, nil) != 0 { // mysql_library_init
            fatalError("could not initialize MySQL library with `mysql_server_init`.")
        }
        $0 = true
    }
}

extension Array where Element == Connection {
    mutating func preparedNewConnection(option: ConnectionOption, pool: ConnectionPool) -> Connection {
        let newConn = Connection(option: option, pool: pool)
        _ = try? newConn.connect()
        append(newConn)
        return newConn
    }
    
    func getUsableConnection() -> Connection? {
        for c in self {
            if c.isInUse == false && c.ping() {
                c.isInUse = true
                return c
            }
        }
        return nil
    }
    
    internal var inUseConnections: Int {
        var count: Int = 0
        for c in self {
            if c.isInUse {
                count += 1
            }
        }
        return count
    }
}

final public class ConnectionPool: CustomStringConvertible {
    
    
    private var initialConnections_: Atomic<Int> = Atomic(1)
    
    public var initialConnections: Int {
        get {
            return initialConnections_.sync { $0 }
        }
        set {
            initialConnections_.syncWriting {
                $0 = newValue
            }
            pool.syncWriting {
                while $0.count < newValue {
                    _  = $0.preparedNewConnection(option: self.option, pool: self)
                }
            }
        }
    }
    
    public var maxConnections: Int {
        get {
            return maxConnections_.sync { $0 }
        }
        set {
            maxConnections_.syncWriting {
                $0 = newValue
            }
        }
    }
    
    private var maxConnections_: Atomic<Int> = Atomic(10)
    
    internal private(set) var pool: Atomic<[Connection]> = Atomic([])
    
    @available(*, deprecated, renamed: "option")
    public var options: ConnectionOption {
        return option
    }
    
    public let option: ConnectionOption
    
    @available(*, deprecated, renamed: "init(option:)")
    public convenience init(options: ConnectionOption) {
        self.init(option: options)
    }
    
    public init(option: ConnectionOption) {
        self.option = option
        
        InitializeMySQLLibrary()
        
        for _ in 0..<initialConnections {
            pool.syncWriting {
                _ = $0.preparedNewConnection(option: option, pool: self)
            }
        }
    }
    public var timeoutForGetConnection: Int {
        get {
            return timeoutForGetConnection_.sync { $0 }
        }
        set {
            timeoutForGetConnection_.syncWriting {
                $0 = newValue
            }
        }
    }
    
    private var timeoutForGetConnection_: Atomic<Int> = Atomic(60)
    
    internal func getConnection() throws -> Connection {
        var connection: Connection? =
        pool.syncWriting {
            if let conn = $0.getUsableConnection() {
                return conn
            }
            if $0.count < maxConnections {
                let conn = $0.preparedNewConnection(option: option, pool: self)
                conn.isInUse = true
                return conn
            }
            return nil
        }
        
        if let conn = connection {
            return conn
        }
        
        let tickInMs = 50 // ms
        var timeoutCount = (timeoutForGetConnection*1000)/tickInMs
        while timeoutCount > 0 {
            usleep(useconds_t(1000*tickInMs))
            connection = pool.sync {
                $0.getUsableConnection()
            }
            if connection != nil {
                break
            }
            timeoutCount -= 1
        }
        
        guard let conn = connection else {
            throw ConnectionError.connectionPoolGetConnectionTimeoutError
        }
        return conn
    }
    
    internal func releaseConnection(_ conn: Connection) {
        pool.sync { _ in
            conn.isInUse = false
        }
    }
    
    public var description: String {
        let inUseConnections = pool.sync {
            $0.inUseConnections
        }
        return "connections:\n\tinitial:\(initialConnections), max:\(maxConnections), in-use:\(inUseConnections)"
    }
}


extension ConnectionPool {
    
    public func execute<T>( _ block: (_ conn: Connection) throws -> T  ) throws -> T {
        let conn = try getConnection()
        defer {
            releaseConnection(conn)
        }
        return try block(conn)
    }
    
    public func execute<T>( _ block: (_ conn: Connection) async throws -> T  ) async throws -> T {
        let conn = try getConnection()
        defer {
            releaseConnection(conn)
        }
        return try await block(conn)
    }
    
}
