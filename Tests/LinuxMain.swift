import XCTest

import MySQLTests
import SQLFormatterTests

var tests = [XCTestCaseEntry]()
tests += MySQLTests.__allTests()
tests += SQLFormatterTests.__allTests()

XCTMain(tests)
