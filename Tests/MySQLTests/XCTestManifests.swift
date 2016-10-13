//
//  XCTestManifests.swift
//  CrawlerKit
//
//  Created by Yusuke Ito on 6/4/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import XCTest

#if !os(OSX)
    public func allTests() -> [XCTestCaseEntry] {
        return [
            testCase( DateTests.allTests ),
            testCase( EscapeTests.allTests ),
            testCase( QueryFormatterTests.allTests ),
            testCase( ConnectionPoolTests.allTests ),
            testCase( ConnectionTests.allTests ),
            testCase( QueryTests.allTests ),
            testCase( BlobQueryTests.allTests ),
            testCase( SQLTypeTests.allTests )
        ]
    }
#endif
