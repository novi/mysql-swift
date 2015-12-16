import PackageDescription

let package = Package(
    name: "MySQL",
    dependencies: [
        .Package(url: "https://github.com/formbound/CMySQL.git", majorVersion: 1)
    ]
)