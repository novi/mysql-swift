import PackageDescription

let package = Package(
    name: "MySQL",
    dependencies: [
        .Package(url: "../CMySQL", majorVersion: 1)
    ]
)