//
//  Model.swift
//  MySQLDemo
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import MySQL

struct Row {
    
    struct User: QueryResultRowType, QueryArgumentDictionaryType {
        let id: Int
        let userName: String
        let age: Int?
        let createdAt: SQLDate
        
        static func decodeRow(r: QueryResult) throws -> User {
            return try build(User.init)(
                r <| 0,
                r <| "name",
                r <|? 2,
                r <| "created_at"
            )
        }
        
        func queryValues() throws -> QueryDictionary {
            return QueryDictionary([
                //"id": // auto increment
                "name": userName,
                "age": age,
                "created_at": createdAt
            ])
        }
    }
    
}