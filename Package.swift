import PackageDescription

let package = Package(
    name: "MySQLSwift",
    targets: [
        Target(name: "SQLFormatter"),
        Target(name: "MySQL", dependencies: ["SQLFormatter"])
    ],
    dependencies: [
        .Package(url: "https://github.com/vapor/cmysql.git", majorVersion: 2),
    ],
    exclude: [
        "Xcode"
    ]
)
