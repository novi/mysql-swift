//
//  Model.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import MySQL

struct Row {
    
    struct UserDecodeWithIndex: QueryRowResultType, QueryParameterDictionaryType {
        let id: Int
        
        let name: String
        let age: Int
        let createdAt: SQLDate
        
        let nameOptional: String?
        let ageOptional: Int?
        let createdAtOptional: SQLDate?
        
        let done: Bool
        let doneOptional: Bool?
        
        static func decodeRow(r: QueryRowResult) throws -> UserDecodeWithIndex {
            return try UserDecodeWithIndex(
                id: r <| 0,
                
                name: r <| 1,
                age: r <| 2,
                createdAt: r <| 3,
                
                nameOptional: r <|? 4,
                ageOptional: r <|? 5,
                createdAtOptional: r <|? 6,
                
                done: r <| 7,
                doneOptional: r <|? 8
            )
        }
        
        func queryParameter() throws -> QueryDictionary {
            return QueryDictionary([
                //"id": // auto increment
                "name": name,
                "age": age,
                "created_at": createdAt,
                
                "name_Optional": nameOptional,
                "age_Optional": ageOptional,
                "created_at_Optional": createdAtOptional,
                
                "done": done,
                "done_Optional": doneOptional
                ])
        }
    }
    
    struct UserDecodeWithKey: QueryRowResultType {
        let id: Int
        
        let name: String
        let age: Int
        let createdAt: SQLDate
        
        let nameOptional: String?
        let ageOptional: Int?
        let createdAtOptional: SQLDate?
        
        let done: Bool
        let doneOptional: Bool?
        
        static func decodeRow(r: QueryRowResult) throws -> UserDecodeWithKey {
            return try UserDecodeWithKey(
                id: r <| "id",
                
                name: r <| "name",
                age: r <| "age",
                createdAt: r <| "created_at",
                
                nameOptional: r <|? "name_Optional",
                ageOptional: r <|? "age_Optional",
                createdAtOptional: r <|? "created_at_Optional",
                
                done: r <| "done",
                doneOptional: r <|? "done_Optional"
            )
        }
    }
    
    struct BlobTextRow: QueryRowResultType, QueryParameterDictionaryType {
        let id: Int
        
        let text1: String
        
        static func decodeRow(r: QueryRowResult) throws -> BlobTextRow {
            return try BlobTextRow(
                id: r <| "id",
                
                text1: r <| "text1"
            )
        }
        
        func queryParameter() throws -> QueryDictionary {
            return QueryDictionary([
                                       //"id": // auto increment
                "text1": text1
                ])
        }
    }
}