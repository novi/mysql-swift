//
//  ConnectionPool.swift
//  MySQL
//
//  Created by ito on 12/24/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

#if os(Linux)
    import Glibc
#endif

import CMySQL

final public class ConnectionPool: CustomStringConvertible {
    
    
    public var initialConnections: Int = 1 {
        didSet {
            while pool.count < initialConnections {
                preparedNewConnection()
            }
        }
    }
    public var maxConnections: Int = 10
    
    internal var pool: [Connection] = []
    private var mutex = Mutex()
    
    private static var libraryInitialized: Bool = false
    
    public let options: ConnectionOption
    public init(options: ConnectionOption) {
        self.options = options
        
        if self.dynamicType.libraryInitialized == false && mysql_server_init(0, nil, nil) != 0 { // mysql_library_init
            fatalError("could not initialize MySQL library")
        }
        self.dynamicType.libraryInitialized = true
        
        
        for _ in 0..<initialConnections {
            preparedNewConnection()
        }
    }
    
    private func preparedNewConnection() -> Connection {
        let newConn = Connection(options: options, pool: self)
        _ = try? newConn.connect()
        pool.append(newConn)
        return newConn
    }
    
    internal func getConnection() throws -> Connection {
        let connection: Connection? =
        mutex.sync {
            for c in pool {
                if c.isInUse == false && c.ping {
                    c.isInUse = true
                    return c
                }
            }
            if pool.count < maxConnections {
                let conn = preparedNewConnection()
                conn.isInUse = true
                return conn
            }
            return nil
        }
        guard let conn = connection else {
            throw Connection.Error.ConnectionPoolGetConnectionError
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
        return "initial: \(initialConnections), max: \(maxConnections), in use: \(inUseConnections)"
    }
}


extension ConnectionPool {
    
    public func execute<T>(@noescape _ block: (conn: Connection) throws -> T  ) throws -> T {
        let conn = try getConnection()
        defer {
            releaseConnection(conn)
        }
        return try block(conn: conn)
    }
    
}
