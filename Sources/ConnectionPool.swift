//
//  ConnectionPool.swift
//  MySQL
//
//  Created by ito on 12/24/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import CMySQL

func Sync<T>(mutex: UnsafeMutablePointer<pthread_mutex_t>, @noescape _ block: () -> T) -> T {
    pthread_mutex_lock(mutex)
    let result = block()
    pthread_mutex_unlock(mutex)
    return result
}

final public class ConnectionPool: CustomStringConvertible {
    
    
    public var initialConnections: Int = 1 {
        didSet {
            while pool.count < initialConnections {
                preparedNewConnection()
            }
        }
    }
    public var maxConnections: Int = 10
    
    var pool: [Connection] = []
    var mutex: UnsafeMutablePointer<pthread_mutex_t> = nil
    
    public let options: Connection.Options
    public init(options: Connection.Options) {
        self.options = options
        
        mutex = UnsafeMutablePointer.alloc(sizeof(pthread_mutex_t))
        pthread_mutex_init(mutex, nil)
        
        for _ in 0..<initialConnections {
            preparedNewConnection()
        }
    }
    
    func preparedNewConnection() -> Connection {
        let newConn = Connection(options: options, pool: self)
        _ = try? newConn.connect()
        pool.append(newConn)
        return newConn
    }
    
    public func getConnection() throws -> Connection {
        let connection: Connection? =
        Sync(mutex) {
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
            throw Connection.Error.ConnectionGetError
        }
        return conn
    }
    
    func releaseConnection(conn: Connection) {
        if conn.isInTransaction > 0 {
            do {
                try conn.rollback()
            } catch(let e) {
                print("rollback failed in release connection: \(e)")
            }
        }
        Sync(mutex) {
            conn.isInUse = false
        }
    }
    
    var inUseConnections: Int {
        return Sync(mutex) {
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
    
    deinit {
        pthread_mutex_destroy(mutex)
    }
    
}


extension ConnectionPool {
    
    public func execute<T>(@noescape block: (conn: Connection) throws -> T  ) throws -> T {
        let conn = try getConnection()
        defer {
            releaseConnection(conn)
        }
        return try block(conn: conn)
    }
    
}
