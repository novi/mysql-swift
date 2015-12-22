import PackageDescription


#if os(OSX)
	let CMySQLURL = "https://github.com/novi/CMySQL-OSX.git"
#else
	let CMySQLURL = "https://github.com/PureSwift/CMySQL.git"
#endif

let package = Package(
    name: "MySQL",
    dependencies: [
        .Package(url: CMySQLURL, majorVersion: 1)
    ]
)