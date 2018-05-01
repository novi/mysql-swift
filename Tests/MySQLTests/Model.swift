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


final class Row {
    private init() { }
}
