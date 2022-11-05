// swift-tools-version:5.6
import PackageDescription

#if os(Linux)
let cMySQLPackageName = "CMariadb"
#else
let cMySQLPackageName = "CMySQL"
#endif

let package = Package(
    name: "mysql-swift",
    products: [
        .library(name: "MySQL", targets: ["MySQL"])
    ],
    targets: [
        .systemLibrary(
            name: "CMySQL",
            path: "Sources/cmysql",
            pkgConfig: "cmysql",
            providers: [
                .brew(["cmysql"]),
                .apt(["libmysqlclient-dev"])
            ]
        ),
        .systemLibrary(
            name: "CMariadb",
            path: "Sources/cmariadb",
            pkgConfig: "cmariadb",
            providers: [
                .brew(["mariadb"]),
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
