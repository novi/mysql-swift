//
//  QueryURLTypeTests.swift
//  MySQLTests
//
//  Created by Yusuke Ito on 5/1/18.
//

import XCTest
@testable import MySQL
import Foundation

extension Row {
    fileprivate struct URLRow: Codable, QueryParameter, Equatable {
        let url: URL
        let urlOptional: URL?
        private enum CodingKeys: String, CodingKey {
            case url = "url"
            case urlOptional = "url_Optional"
        }
    }
}


final class QueryURLTypeTests: XCTestCase, QueryTestType {
    var constants: TestConstantsType!
    var pool: ConnectionPool!
    
    override func setUp() {
        super.setUp()
        
        prepare()
        try! createURLTestTable()
    }
    
    private func createURLTestTable() throws {
        try dropTestTable()
        
        let conn = try pool.getConnection()
        let query = """
        CREATE TABLE `\(constants.tableName)` (
        `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
        `url` mediumtext NOT NULL,
        `url_Optional` mediumtext,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        """
        
        _ = try conn.query(query)
    }
    
    
    
    func testURLType() throws {
        
        let urlRow1 = Row.URLRow(url: URL(string: "https://apple.com/iphone")!, urlOptional: nil)
        let urlRow2 = Row.URLRow(url: URL(string: "https://apple.com/iphone")!, urlOptional: URL(string: "https://apple.com/ipad")!)
        
        try pool.execute { conn in
            _ = try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, urlRow1])
            _ = try conn.query("INSERT INTO ?? SET ? ", [constants.tableName, urlRow2])
        }
        
        let rows: [Row.URLRow] = try pool.execute {
            try $0.query("SELECT * FROM ?? ORDER BY id ASC", [constants.tableName])
        }
        
        XCTAssertEqual(rows[0], urlRow1)
        XCTAssertEqual(rows[1], urlRow2)
    }
    
    func testURLInvalid() throws {
        
        try pool.execute { conn in
            _ = try conn.query("INSERT INTO ?? SET `url` = ''", [constants.tableName])
        }
        
        do {
            let _: [Row.URLRow] = try pool.execute {
                try $0.query("SELECT * FROM ?? ORDER BY id ASC", [constants.tableName])
            }
        } catch let error as DecodingError {
            switch error {
            case .dataCorrupted(let context):
                print(context)
            // expected error
            default:
                XCTFail("unexpected error \(error)")
            }
        } catch {
            XCTFail("unexpected error \(error)")
        }
    }
    
}
