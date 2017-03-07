import PackageDescription

let package = Package(
    name: "MySQL",
    targets: [
        Target(name: "CMySQL"),
        Target(name: "SQLFormatter"),
        Target(name: "MySQL", dependencies: ["CMySQL", "SQLFormatter"])
    ],
    exclude: [
        "OSX Projects", "Xcode"
    ]
)
