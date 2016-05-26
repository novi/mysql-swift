mysql-swift
===========

[![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg)](https://swift.org)
![Platform Linux, OSX](https://img.shields.io/badge/Platforms-Linux%2C%20OSX-lightgray.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Travis CI](https://travis-ci.org/novi/mysql-swift.svg)](https://travis-ci.org/novi/mysql-swift)



MySQL client library for Swift.
This is inspired by Node.js' [mysql](https://github.com/felixge/node-mysql) and [Himotoki](https://github.com/ikesyo/Himotoki) as decoding results.

* Based on libmysqlclient
* Raw SQL query
* Simple query formatting and escaping (same as Node's)
* Decoding and mapping queried results to struct

_Note:_ No asynchronous support currently. It depends libmysqlclient.

```swift
// Declare a model

struct User: QueryRowResultType, QueryParameterDictionaryType {
    let id: Int
    let userName: String
    let age: Int?
    let status: Status
    let createdAt: SQLDate
    
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
let user = User(id: 0, userName: "novi", age: age, createdAt: SQLDate.now())
let status = try conn.query("INSERT INTO users SET ?", [user]) as QueryStatus
let newId = status.insertedId
        
// Updating
let defaultAge = 30
try conn.query("UPDATE users SET age = ? WHERE age is NULL;", [defaultAge])
            
        
``` 

# Requirements

* Swift 3 (development snapshot)

# Dependencies

* MariaDB Connector/C (libmysqlclient) 2.2.3

# Installation

## OS X

* Install `mariadb`(includes libmysqlclient).


```sh
$ brew install mariadb
```

## Ubuntu Linux

* Install `libmysqlclient`
* Follow [Setting up MariaDB Repositories](https://downloads.mariadb.org/mariadb/repositories/#mirror=yamagata-university) and set up your repository for operating system.

```sh
$ sudo apt-get install libmariadbclient-dev
```

* Add `mysql-swift` to `Package.swift` of your project.

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/novi/mysql-swift.git", majorVersion: 0, minor: 2)
    ]
)
```

_Note:_ To build with Swift Package Manager(`swift build`), you may need to specify library path for libmysql to link it.

```sh
# Linux
swift build -Xlinker -L/usr/lib
# OS X 
swift build -Xlinker -L/usr/local/lib -Xcc -I/usr/local/include -Xcc -I/usr/local/include/mysql
```

# Usage

## Connection & Querying

1. Create a pool with options (hostname, port, password,...).
2. Get a connection from the pool.
3. Execute query and fetch rows or status.
4. Back the connection to the pool (as `release`),

```swift
	let options = Options(host: "db.example.tokyo"...)
	let pool = ConnectionPool(options: options) // Create pool with options
	
	let conn = try pool.getConnection() // Get free connection
	conn.query("SELECT 1 + 2;")
	conn.release() // Release and back connection to the pool
```

or You can just use `pool.execute()`. It automatically get and release connection. 

```swift
	let rows: [User] = try pool.execute { conn in
		// The connection is held in this block
		try conn.query("SELECT * FROM users;") // And also it returns result to outside execute block
	}
```

## Transaction

```swift
	let options = Options(host: "db.example.tokyo"...)
	let pool = ConnectionPool(options: options) // Create pool with options
	
	let wholeStaus: QueryStatus = try pool.transaction { conn in
		let status = try conn.query("INSERT INTO users SET ?;", [user]) as QueryStatus // Create a user
		let userId = status.insertedId // the user's id
		try conn.query("UPDATE info SET val = ? WHERE key = 'latest_user_id' ", [userId]) // Store user's id that we have created the above
	}
	wholeStaus.affectedRows == 1 // true
```



# License

MIT
