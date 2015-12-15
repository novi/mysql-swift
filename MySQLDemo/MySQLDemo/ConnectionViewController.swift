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
`name` varchar(11) DEFAULT NULL,
`age` int(11) DEFAULT NULL,
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
            let (rows, status) = try conn.query(queryField.stringValue, []) as ([Row.User], Connection.Status)
            for row in rows {
                //print(row)
                print("\(row.id) : \(row.userName) \(row.age)")
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
            //let status = try conn.query("INSERT INTO users SET name = ?, age = ?", [QueryArgumentValueString("test user ' "), QueryArgumentValueInt(random()%100)]) as Connection.Status
            
            let user = Row.User(id: 0, userName: "test ' user", age: random()%100)
            let status = try conn.query("INSERT INTO users SET ?", [user]) as Connection.Status

            print(status)
            
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