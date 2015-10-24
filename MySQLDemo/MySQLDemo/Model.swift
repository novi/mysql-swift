//
//  Model.swift
//  MySQLDemo
//
//  Created by ito on 2015/10/24.
//  Copyright © 2015年 Yusuke Ito. All rights reserved.
//

import Foundation
import Himotoki

struct Row {
    
    struct User: Decodable {
        let id: Int
        let userName: String
        let age: Int?
        static func decode(e: Extractor) throws -> User {
            return try build(User.init)(
                e <| "id",
                e <| "user_name",
                e <|? "age"
            )
        }
    }
    
}