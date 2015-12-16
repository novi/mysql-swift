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
        let createdAt: SQLDate
        
        static func decodeRow(r: QueryResult) throws -> User {
            return try build(User.init)(
                r <| "id",
                r <| "name",
                r <|? "age",
                r <| "created_at"
                //,r <| "ages"
            )
        }
        func escapedValue() throws -> String {
            return try QueryDictionary([
                //"id": // auto increment
                "name": userName,
                "age": age,
                "created_at": createdAt
            ]).escapedValue()
        }
        
    }
    
}