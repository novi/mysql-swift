mysql-swift
===========

[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg)](https://swift.org)
![Platform Linux, macOS](https://img.shields.io/badge/Platforms-Linux%2C%20macOS-lightgray.svg)
[![Build Status](https://travis-ci.org/novi/mysql-swift.svg?branch=master)](https://travis-ci.org/novi/mysql-swift)



MySQL client library for Swift.
This is inspired by Node.js' [mysql](https://github.com/felixge/node-mysql) and [Himotoki](https://github.com/ikesyo/Himotoki) as decoding results.

* Based on libmysqlclient
* Raw SQL query
* Simple query formatting and escaping (same as Node's)
* Decoding and mapping queried results to Swift struct or class

_Note:_ No asynchronous support currently. It depends libmysqlclient.

```swift
// Declare a model

struct User: QueryRowResultType, QueryParameterDictionaryType {
    let id: Int
    let userName: String
    let age: Int?
    let status: Status
    let createdAt: Date
    
    enum Status: String, SQLEnumType {
        case created = "created"
        case verified = "verified"
    }
    
    // Decode query results (selecting rows) to a model
    static func decodeRow(r: QueryRowResult) throws -> User {
        return try User(
            id: r <| 0, // as index
            userName: r <| "name", // as field name
            age: r <|? 3, // nullable field,
            status: r <| "status", // string enum type
            createdAt: r <| "created_at"
        )
    }
    
    // Use this model as a query paramter
    // See inserting example
    func queryParameter() throws -> QueryDictionary {
        return QueryDictionary([
            //"id": // auto increment
            "name": userName,
            "age": age,
            "status": status,
            "created_at": createdAt
        ])
    }
}
    
// Selecting
let nameParam: String = "some one"
let ids: [QueryParameter] = [1, 2, 3, 4, 5, 6]
let optional:Int? = nil
let params: (Int, Int?, String, QueryArray) = (
	50,
	optional,
	nameParam,
	QueryArray(ids)
)	
let rows: [User] = try conn.query("SELECT id,name,created_at,age FROM users WHERE (age > ? OR age is ?) OR name = ? OR id IN (?)", build(params) ])

// Inserting
let age: Int? = 26
let user = User(id: 0, userName: "novi", age: age, createdAt: Date())
let status = try conn.query("INSERT INTO users SET ?", [user]) as QueryStatus
let newId = status.insertedId
        
// Updating
let defaultAge = 30
try conn.query("UPDATE users SET age = ? WHERE age is NULL;", [defaultAge])
            
        
``` 

# Requirements

* Swift 4.0

(If you are using Swift 3.1, use `0.7.4` tagged version.)

# Dependencies

* MariaDB or MySQL Connector/C (libmysqlclient) 2.2.3

## macOS

This library uses Vapor's `cmysql` . Follow [the instruction](https://docs.vapor.codes/2.0/getting-started/install-on-macos/).

## Ubuntu Linux

* Install `libmariadbclient`
* Follow [Setting up MariaDB Repositories](https://downloads.mariadb.org/mariadb/repositories/#mirror=yamagata-university) and set up your repository.

```sh
$ sudo apt-get install libmariadbclient-dev
```

# Installation

## Swift Package Manager

* Add `mysql-swift` to `Package.swift` of your project.

```swift
// swift-tools-version:4.0
import PackageDescription

let package = Package(
    ...,
    dependencies: [
        .package(url: "https://github.com/novi/mysql-swift.git", .upToNextMinor(from: "0.8.0"))
    ],
    targets: [
        .target(
            name: "YourAppOrLibrary",
            dependencies: [
                // add a dependency
                "MySQL", 
            ]
        )
    ]
)
```

# Usage

## Connection & Querying

1. Create a pool with options (hostname, port, password,...).
2. Use `pool.execute()`. It automatically get and release a connection. 

```swift
let options = Options(host: "your.mysql.host"...)
let pool = ConnectionPool(options: options) // Create pool with options
let rows: [User] = try pool.execute { conn in
	// The connection is held in this block
	try conn.query("SELECT * FROM users;") // And it returns result to outside execute block
}
```

## Transaction

```swift	
let wholeStaus: QueryStatus = try pool.transaction { conn in
	let status = try conn.query("INSERT INTO users SET ?;", [user]) as QueryStatus // Create a user
	let userId = status.insertedId // the user's id
	try conn.query("UPDATE info SET val = ? WHERE key = 'latest_user_id' ", [userId]) // Store user's id that we have created the above
}
wholeStaus.affectedRows == 1 // true
```



# License

MIT
