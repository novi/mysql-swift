//
//  Model.swift
//  MySQLDemo
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import Foundation
import MySQL

struct Row {
    
    struct User: QueryResultRowType, QueryArgumentValueType {
        let id: Int
        let userName: String
        let age: Int?
        //let ages: Bool
        
        static func fromRow(r: QueryResult) throws -> User {
            return try build(User.init)(
                r <| "id",
                r <| "name",
                r <|? "age"
                //,r <| "ages"
            )
        }
        func escapedValue() throws -> String {
            return try QueryArgumentValueDictionary([
                //"id": QueryArgumentValueInt(id), // auto increment
                "name": QueryArgumentValueString(userName),
                "age": QueryArgumentValueInt(age)
            ]).escapedValue()
        }
        
    }
    
}