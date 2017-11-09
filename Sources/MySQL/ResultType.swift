//
//  ResultTypes.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/28/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Foundation

extension Int: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Int {
        guard let val = Int(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension UInt: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> UInt {
        guard let val = UInt(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension Int64: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Int64 {
        guard let val = Int64(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension Int32: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Int32 {
        guard let val = Int32(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension Int16: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Int16 {
        guard let val = Int16(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension Int8: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Int8 {
        guard let val = Int8(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension UInt64: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> UInt64 {
        guard let val = UInt64(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension UInt32: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> UInt32 {
        guard let val = UInt32(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension UInt16: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> UInt16 {
        guard let val = UInt16(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension UInt8: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> UInt8 {
        guard let val = UInt8(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension Float: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Float {
        guard let val = Float(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension Double: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Double {
        guard let val = Double(string) else {
            throw QueryError.initializationError
        }
        return val
    }
}

extension String: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> String {
        return string
    }
}

extension Bool: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Bool {
        guard let val = Int(string) else {
            throw QueryError.initializationError
        }
        return Bool(val == 0 ? false : true )
    }
}


extension Date: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Date {
        fatalError("invalid constructor (use init instead)")
    }
}
