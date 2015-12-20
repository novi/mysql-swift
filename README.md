mysql-swift
===========

MySQL client library for Swift.
This is inspired by Node.js' [mysql](https://github.com/felixge/node-mysql) and [Himotoki](https://github.com/ikesyo/Himotoki) as decoding results.

* Based on libmysqlclient
* Raw SQL query
* Simple query formatting and escaping (same as Node's)
* Decoding and mapping selecting results to struct

_Note:_ No asynchronous support currently. It depends libmysqlclient.

```swift
// Declare a model

struct User: QueryRowResultType, QueryArgumentDictionaryType {
    let id: Int
    let userName: String
    let age: Int?
    let createdAt: SQLDate
    
    // Decode query results (selecting rows) to the model
    // see selecting sample
    static func decodeRow(r: QueryRowResult) throws -> User {
        return try build(User.init)(
            r <| 0, // as index
            r <| "name", // as field name
            r <|? 3,
            r <| "created_at"
        )
    }
    
    // Use the model as a query paramter
    // see inserting sample
    func queryValues() throws -> QueryDictionary {
        return QueryDictionary([
            //"id": // auto increment
            "name": userName,
            "age": age,
            "created_at": createdAt
        ])
    }
}
    
// Selecting
let nameParam: String = "some one"
let ids: [Int] = [1, 2, 3, 4, 5, 6]
let optional:Int? = nil
let params: (Int, Int?, String, QueryArray<Int>) = (
	50,
	optional,
	nameParam,
	QueryArray<Int>(ids)
)	
let rows: [User] = try conn.query("SELECT id,name,created_at,age FROM users WHERE (age > ? OR age is ?) OR name = ? OR id IN (?)", buildParam(params) ])

// Inserting
let age: Int? = 26
let user = User(id: 0, userName: "novi", age: age, createdAt: SQLDate.now(timeZone: conn.options.timeZone))
let status = try conn.query("INSERT INTO users SET ?", [user]) as QueryStatus
let newId = status.insertedId
        
// Updating
let defaultAge = 30
try conn.query("UPDATE users SET age = ? WHERE age is NULL;", [defaultAge])
            
        
``` 

# Requirements

* Swift 2.1 or Later (includes Linux support)
* OS X 10.10 or Later

# Dependencies

* libmysqlclient 6.1.6 or Later (named CMySQL in Swift)

# License

MIT
