//
//  ViewController.swift
//  MySQLDemo
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import Cocoa
import MySQL

class ViewController: NSViewController {

    
    @IBOutlet weak var hostField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var userField: NSTextField!
    @IBOutlet weak var passwordField: NSTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func connectTapped(sender: AnyObject) {
        
        let info = Database.ConnectionInfo(host: hostField.stringValue, port: Int(portField.stringValue) ?? 0, userName: userField.stringValue, password: passwordField.stringValue, database: "test")
        let database = Database(info: info)
        do {
            let conn = try database.getConnection()
            
            let rows: [Row.User] = try conn.query("SELECT * FROM users", args:[])
            for row in rows {
                print("\(row.id) : \(row.userName) \(row.age)")
            }
            
        } catch (let e) {
            print("\(e as ErrorType)")
            let err = NSError(domain: "MySQL", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "\(e as ErrorType)"
                ])
            self.presentError(err)
        }
        
    }


}

