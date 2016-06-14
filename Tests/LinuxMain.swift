import XCTest
import MySQLTestSuite
import SQLFormatterTestSuite

var tests = [XCTestCaseEntry]()

tests += MySQLTestSuite.allTests()
tests += SQLFormatterTestSuite.allTests()

XCTMain(tests)
