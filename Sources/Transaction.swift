//
//  Connection-Transaction.swift
//  MySQL
//
//  Created by ito on 12/24/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//


extension Connection {
    
    public func beginTransaction() throws {
        try query(query: "START TRANSACTION;") as ([EmptyRowResult], QueryStatus)
        isInTransaction += 1
    }

    public func commit() throws {
        isInTransaction = 0
        try query(query: "COMMIT;") as ([EmptyRowResult], QueryStatus)
    }
    
    public func rollback() throws {
        if isInTransaction > 0 {
            isInTransaction = 0
            
        }
        try query(query: "ROLLBACK;") as ([EmptyRowResult], QueryStatus)
    }
}

extension ConnectionPool {
    
    public func transaction<T>(@noescape block: (conn: Connection) throws -> T  ) throws -> T {
        let conn = try getConnection()
        defer {
            releaseConnection(conn)
        }
        try conn.beginTransaction()
        do {
            let result = try block(conn: conn)
            try conn.commit()
            return result
        } catch (let e) {
            do {
                try conn.rollback()
            } catch (let e) {
                print(e)
            }
            throw e
        }
    }
}