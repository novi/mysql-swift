//
//  ConnectionViewController.swift
//  MySQLDemo
//
//  Created by ito on 2015/10/26.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import Cocoa
import MySQL


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
            let rows: [Row.User] = try conn.query(queryField.stringValue, args:[])
            for row in rows {
                //print(row)
                print("\(row.id) : \(row.userName) \(row.age)")
            }
            self.users = rows
            tableView.reloadData()
            
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