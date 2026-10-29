// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "mysql-swift",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "MySQL", targets: ["MySQL"])
    ],
    targets: [
        .systemLibrary(
            name: "CMySQL",
            path: "Sources/cmysql",
            pkgConfig: "mysqlclient",
            providers: [
                .brew(["mysql-client"]),
                .apt(["libmysqlclient-dev"])
            ]
        ),
        .target(
            name: "SQLFormatter"
        ),
        .target(
            name: "MySQL",
            dependencies: [
                .byName(name: "CMySQL"),
                "SQLFormatter",
            ]
        ),
        .testTarget(
            name: "MySQLTests",
            dependencies: [
                "MySQL"
            ]
        ),
        .testTarget(
            name: "SQLFormatterTests",
            dependencies: [
                "MySQL"
            ]
        )
    ]
)
