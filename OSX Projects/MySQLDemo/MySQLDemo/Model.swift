//
//  Model.swift
//  MySQLDemo
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import MySQL

struct Row {
    
    struct User: QueryRowResultType, QueryParameterDictionaryType {
        let id: Int
        let userName: String
        let age: Int?
        let createdAt: SQLDate
        
        static func decodeRow(r: QueryRowResult) throws -> User {
            return try build(User.init)(
                r <| 0, // access with index
                r <| "name", // access with key
                r <|? 3,
                r <| "created_at"
            )
        }
        
        func queryParameter() throws -> QueryDictionary {
            return QueryDictionary([
                //"id": // auto increment
                "name": userName,
                "age": age,
                "created_at": createdAt
            ])
        }
    }
    
}