//
//  ConnectionViewController.swift
//  MySQLDemo
//
//  Created by ito on 2015/10/26.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import Cocoa
import MySQL

/*

// Demo Table Scheme

CREATE TABLE `users` (
`id` int(11) unsigned NOT NULL AUTO_INCREMENT,
`name` varchar(50) NOT NULL DEFAULT '',
`age` int(11) DEFAULT NULL,
`created_at` datetime NOT NULL,
PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

*/

class ConnectionViewController: NSViewController, NSTableViewDataSource {
    
    var pool: ConnectionPool!
    
    @IBOutlet weak var queryField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var users: [Row.User] = []
    
    @IBAction func runTapped(sender: AnyObject) {
        let query = queryField.stringValue
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            do {
                print("before execute", self.pool)
                
                let ageMin: Int = random()%100
                let (rows, status): ([Row.User], QueryStatus) = try self.pool.execute { conn in
                    let res = try conn.query(query, [ageMin]) as ([Row.User], QueryStatus)
                    sleep(UInt32(random()%10))
                    return res
                }
                
                for row in rows {
                    print(row)
                }
                
                print(status)
                
                print("after execute", self.pool)
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.users = rows
                    self.tableView.reloadData()
                })
                
            } catch (let e) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentError(NSError(domain: "", code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "\(e as ErrorType)"
                        ]))
                }
            }
        }
    }
    
    @IBAction func insertTapped(sender: AnyObject) {

        do {
            var optionalIntVal: Int? = random()%100
            let params: (String, Int?, SQLDate) = (
                "test user",
                optionalIntVal,
                SQLDate.now(timeZone: pool.options.timeZone)
            )            
            
            let status1 = try pool.execute { conn in
                try conn.query("INSERT INTO users SET name = ?, age = ?, created_at = ?", build(params) ) as QueryStatus
            }
            
            print(status1)
            
            optionalIntVal = nil
            
            let status2 = try pool.transaction { conn in
                
                let user = Row.User(id: 0, userName: "test ' user 日本語 _ % ", age: optionalIntVal, createdAt: SQLDate.now(timeZone: conn.options.timeZone))
                
                let status = try conn.query("INSERT INTO users SET ?", [user])
                
                try conn.query("IN VALID Query;;;")
                return status
            } as QueryStatus
            
            print(status2)
            
            
        } catch (let e) {
            self.presentError(NSError(domain: "", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "\(e as ErrorType)"
                ]))
        }
    }
    
    
    // MARK: Table View
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return users.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        let user = users[row]
        switch tableColumn?.identifier ?? "" {
            case "id":
                return user.id
            case "name":
                return user.userName
            case "age":
                if let age = user.age {
                    return "\(age)"
                } else {
                    return "NULL"
                }
        default:
            return nil
        }
    }
}