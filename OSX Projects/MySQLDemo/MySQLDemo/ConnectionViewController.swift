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
    
    var connection: Connection?
    
    @IBOutlet weak var queryField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    var users: [Row.User] = []
    
    @IBAction func runTapped(sender: AnyObject) {
        guard let conn = self.connection else {
            return
        }
        
        do {
            let ageMin: Int = random()%100
            let (rows, status) = try conn.query(queryField.stringValue, [ageMin]) as ([Row.User], QueryStatus)
            for row in rows {
                print(row)
                //print("\(row.id) : \(row.userName) \(row.age) \(row.createdAt)")
            }
            
            print(status)
            
            self.users = rows
            tableView.reloadData()
            
        } catch (let e) {
            self.presentError(NSError(domain: "", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "\(e as ErrorType)"
                ]))
        }
    }
    
    @IBAction func insertTapped(sender: AnyObject) {
        guard let conn = self.connection else {
            return
        }
        
        do {
            var optionalIntVal: Int? = random()%100
            let params: (String, Int?, SQLDate) = (
                "test user",
                optionalIntVal,
                SQLDate.now(timeZone: conn.options.timeZone)
            )            
            
            let status1 = try conn.query("INSERT INTO users SET name = ?, age = ?, created_at = ?", buildParam(params) ) as QueryStatus
            
            print(status1)
            
            optionalIntVal = nil
            
            let user = Row.User(id: 0, userName: "test ' user 日本語 _ % ", age: optionalIntVal, createdAt: SQLDate.now(timeZone: conn.options.timeZone))
            let status2 = try conn.query("INSERT INTO users SET ?", [user]) as QueryStatus

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