import PackageDescription

let package = Package(
    name: "MySQL",
    targets: [
                 Target(name: "SQLFormatter"),
                 Target(name: "MySQL", dependencies: ["SQLFormatter"])
    ],
    dependencies: [
        .Package(url: "https://github.com/novi/CMySQL-MariaDB.git", majorVersion: 3)
    ],
    exclude: [
        "Carthage", "OSX Projects"
    ]
)
