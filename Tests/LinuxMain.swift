import XCTest
import MySQLTests
import SQLFormatterTests

var tests = [XCTestCaseEntry]()

tests += MySQLTests.allTests()
tests += SQLFormatterTests.allTests()

XCTMain(tests)
