// swift-tools-version:5.6
import PackageDescription

#if os(Linux)
let cMySQLPackageName = "CMySQL" //"CMariadb"
#else
let cMySQLPackageName = "CMySQL"
#endif

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
            pkgConfig: "cmysql",
            providers: [
                .brew(["novi/tap/cmysql"]),
                .apt(["libmysqlclient-dev"])
            ]
        ),
        .systemLibrary(
            name: "CMariadb",
            path: "Sources/cmariadb",
            pkgConfig: "cmariadb",
            providers: [
                .brew(["novi/tap/cmysqlmariadb"]),
                .apt(["libmariadbclient-dev"])
            ]
        ),
        .target(
            name: "SQLFormatter"
        ),
        .target(
            name: "MySQL",
            dependencies: [
                .byName(name: cMySQLPackageName),
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
