//
//  Model.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import MySQL
import Foundation

struct UserID: IDType {
    let id: Int
    init(_ id: Int) {
        self.id = id
    }
}

struct BlobTextID: IDType {
    let id: Int
    init(_ id: Int) {
        self.id = id
    }
}

struct SomeStringID: IDType {
    let id: String
    init(_ id: String) {
        self.id = id
    }
}


struct Row {
    
    struct SimpleUser: Codable {
        let id: UInt
        let name: String
        let age: Int
    }
    
    enum UserType: String, Codable {
        case user = "user"
        case admin = "admin"
    }
    
    struct User: Codable, QueryParameter {
        let id: AutoincrementID<UserID>
        
        let name: String
        let age: Int
        let createdAt: Date
        
        let nameOptional: String?
        let ageOptional: Int?
        let createdAtOptional: Date?
        
        let done: Bool
        let doneOptional: Bool?
        
        let userType: UserType
        
        private enum CodingKeys: String, CodingKey {
            case id
            case name
            case age
            case createdAt = "created_at"
            case nameOptional = "name_Optional"
            case ageOptional = "age_Optional"
            case createdAtOptional = "created_at_Optional"
            case done
            case doneOptional = "done_Optional"
            case userType = "user_type"
        }
    }
    
    struct BlobTextRow: Codable, QueryParameter {
        let id: AutoincrementID<BlobTextID>
        
        let text1: String
        let binary1: Data
    }
    
    struct URLRow: Codable, QueryParameter, Equatable {
        let url: URL
        let urlOptional: URL?
        private enum CodingKeys: String, CodingKey {
            case url = "url"
            case urlOptional = "url_Optional"
        }
    }
}
