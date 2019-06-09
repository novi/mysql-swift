mysql-swift
===========

![Platform Linux, macOS](https://img.shields.io/badge/Platforms-Linux%2C%20macOS-lightgray.svg)
[![CircleCI](https://circleci.com/gh/novi/mysql-swift.svg?style=svg)](https://circleci.com/gh/novi/mysql-swift)



MySQL client library for Swift.
This is inspired by Node.js' [mysql](https://github.com/mysqljs/mysql).

* Based on libmysqlclient
* Raw SQL query
* Simple query formatting and escaping (same as Node's)
* Mapping queried results to `Codable` structs or classes

_Note:_ No asynchronous I/O support currently. It depends libmysqlclient.

```swift
// Declare a model

struct User: Codable, QueryParameter {
    let id: Int
    let userName: String
    let age: Int?
    let status: Status
    let createdAt: Date
    
    enum Status: String, Codable {
        case created = "created"
        case verified = "verified"
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case age
        case status = "status"
        case createdAt = "created_at"
    }
}
    
// Selecting
let nameParam = "some one"
let ids: [QueryParameter] = [1, 2, 3, 4, 5, 6]
let optionalInt: Int? = nil
let rows: [User] = try conn.query("SELECT id,user_name,status,status,created_at FROM `user` WHERE (age > ? OR age is ?) OR name = ? OR id IN (?)", [50, optionalInt, nameParam, QueryArray(ids)] ])

// Inserting
let age: Int? = 26
let user = User(id: 0, userName: "novi", age: age, status: .created, createdAt: Date())
let status = try conn.query("INSERT INTO `user` SET ?", [user]) as QueryStatus
let newId = status.insertedId

// Updating
let tableName = "user"
let defaultAge = 30
try conn.query("UPDATE ?? SET age = ? WHERE age is NULL;", [tableName, defaultAge])

``` 

# Requirements

* Swift 4.1 or later
* MariaDB or MySQL Connector/C (libmysqlclient) 2.2.3 or later

## macOS

Install pkg-config `.pc` file in [cmysql](https://github.com/vapor-community/cmysql) or [cmysql-mariadb](https://github.com/novi/cmysql-mariadb/tree/mariadb).

```sh
# cmysql
$ brew install https://gist.githubusercontent.com/novi/c6d4afa6e9f9cc9c426e3ccd140c3c74/raw/7130ad1d5062cdb2f7492d42e8d5574b864f3e18/cmysql.rb
# cmysql-mariadb
$ brew install https://gist.githubusercontent.com/novi/dd21d48d260379e8919d9490bf5cfaec/raw/6ea4daa02d93f4ab0110ad30d87ea2b497a71cd0/cmysqlmariadb.rb
```

## Ubuntu

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
        .package(url: "https://github.com/novi/mysql-swift.git", .upToNextMajor(from: "0.9.0"))
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
2. Use `ConnectionPool.execute()`. It automatically get and release a connection. 

```swift
let option = Option(host: "your.mysql.host"...) // Define and create your option type
let pool = ConnectionPool(option: option) // Create a pool with the option
let rows: [User] = try pool.execute { conn in
	// The connection `conn` is held in this block
	try conn.query("SELECT * FROM users;") // And it returns result to outside execute block
}
```

## Transaction

```swift	
let wholeStaus: QueryStatus = try pool.transaction { conn in
	let status = try conn.query("INSERT INTO users SET ?;", [user]) as QueryStatus // Create a user
	let userId = status.insertedId // the user's id
	try conn.query("UPDATE info SET some_value = ? WHERE some_key = 'latest_user_id' ", [userId]) // Store user's id that we have created the above
}
wholeStaus.affectedRows == 1 // true
```



# License

MIT
