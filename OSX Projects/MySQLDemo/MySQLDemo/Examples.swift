//
//  Examples.swift
//  MySQLDemo
//
//  Created by ito on 12/18/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import MySQL

struct Examples {
    
    var conn: Connection!
    
    func selectRows() throws -> [Row.User] {
        let nameParam: String = "test"
        let ids: [Int] = [1, 2, 3, 4, 5, 6]
        let optional:Int? = nil
        let rows: [Row.User] = try conn.query("SELECT id,name,created_at,age FROM users WHERE (age > ? OR age is ?) OR name = ? OR id in (?)", [50, QueryOptional(optional), nameParam, QueryArray(ids) ])
        return rows
    }
    
    func insertRow() throws -> Int {
        let age: Int? = 26
        let user = Row.User(id: 0, userName: "test", age: age, createdAt: SQLDate.now(timeZone: conn.options.timeZone))
        let status = try conn.query("INSERT INTO users SET ?", [user]) as QueryStatus
        if status.affectedRows != 1 {
            // insert failed
        }
        return status.insertedId
    }
    
    func updateSomeRows() throws -> Int {
        let defaultAge = 30
        let status: QueryStatus = try conn.query("UPDATE users SET age = ? WHERE age is NULL;", [defaultAge])
        return status.affectedRows // number of rows updated
    }
}