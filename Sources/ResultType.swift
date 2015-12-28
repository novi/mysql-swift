//
//  ResultTypes.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/28/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

extension Int: StringConstructible {
    public static func from(string string: String) -> Int? {
        return Int(string)
    }
}

extension Int64: StringConstructible {
    public static func from(string string: String) -> Int64? {
        return Int64(string)
    }
}

extension Float: StringConstructible {
    public static func from(string string: String) -> Float? {
        return Float(string)
    }
}

extension Double: StringConstructible {
    public static func from(string string: String) -> Double? {
        return Double(string)
    }
}

extension String: StringConstructible {
    public static func from(string string: String) -> String? {
        return string
    }
}

extension Bool: StringConstructible {
    public static func from(string string: String) -> Bool? {
        guard let val = Int(string) else {
            return nil
        }
        return Bool(val)
    }
}


extension SQLDate: StringConstructible {
    public static func from(string string: String) -> SQLDate? {
        return nil // Invalid Constructor (use init instead)
    }
}
