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

final public class ConnectionPool: CustomStringConvertible {
    
    
    public var initialConnections: Int = 1 {
        didSet {
            while pool.count < initialConnections {
                _ = preparedNewConnection()
            }
        }
    }
    
    public var maxConnections: Int = 10
    
    internal private(set) var pool: [Connection] = []
    private var mutex = Mutex()
    
    private static var libraryInitialized: Bool = false
    
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
        
        if type(of: self).libraryInitialized == false && mysql_server_init(0, nil, nil) != 0 { // mysql_library_init
            fatalError("could not initialize MySQL library with `mysql_server_init`.")
        }
        type(of: self).libraryInitialized = true
        
        
        for _ in 0..<initialConnections {
            _ = preparedNewConnection()
        }
    }
    
    private func preparedNewConnection() -> Connection {
        let newConn = Connection(option: option, pool: self)
        _ = try? newConn.connect()
        pool.append(newConn)
        return newConn
    }
    
    private func getUsableConnection() -> Connection? {
        for c in pool {
            if c.isInUse == false && c.ping() {
                c.isInUse = true
                return c
            }
        }
        return nil
    }
    
    public var timeoutForGetConnection: Int = 60
    
    internal func getConnection() throws -> Connection {
        var connection: Connection? =
        mutex.sync {
            if let conn = getUsableConnection() {
                return conn
            }
            if pool.count < maxConnections {
                let conn = preparedNewConnection()
                conn.isInUse = true
                return conn
            }
            return nil
        }
        
        if let conn = connection {
            return conn
        }
        
        let tickInMs = 50 // ms
        var timeOutCount = (timeoutForGetConnection*1000)/tickInMs
        while timeOutCount > 0 {
            usleep(useconds_t(1000*tickInMs))
            connection = mutex.sync {
                getUsableConnection()
            }
            if connection != nil {
                break
            }
            timeOutCount -= 1
        }
        
        guard let conn = connection else {
            throw ConnectionError.connectionPoolGetConnectionError
        }
        return conn
    }
    
    internal func releaseConnection(_ conn: Connection) {
        mutex.sync {
            conn.isInUse = false
        }
    }
    
    internal var inUseConnections: Int {
        return mutex.sync {
            var count: Int = 0
            for c in pool {
                if c.isInUse {
                    count += 1
                }
            }
            return count
        } as Int
    }
    
    public var description: String {
        return "initial connection: \(initialConnections), max: \(maxConnections), in use: \(inUseConnections)"
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
    
}
