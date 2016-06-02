//
//  Blob.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/22/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import SQLFormatter

public struct SQLBinary {
    let buffer: [Int8]
    let length: Int
    public var data: [Int8] {
        if buffer.count == length {
            return buffer
        }
        return Array(buffer[0..<length])
    }
    public init(_ data: [Int8] = []) {
        self.buffer = data
        self.length = data.count
    }
    public init(_ data: [UInt8]) {
        self.buffer = unsafeBitCast(data, to: [Int8].self)
        self.length = data.count
    }
    
    init(buffer: [Int8], length: Int) {
        self.buffer = buffer
        self.length = length
    }
}

extension SQLBinary: SQLStringDecodable {
    public static func from(string: String) -> SQLBinary? {
        fatalError("construct via init(binary:)")
    }
}

extension SQLBinary: QueryParameterType {
    public func escaped() -> String {
        var buffer = "x'"
        for d in data {
            let unsigned = unsafeBitCast(d, to: UInt8.self)
            let str = String(unsigned, radix: 16)
            if str.characters.count == 1 {
                buffer.append("0")
            }
            buffer.append(str)
        }
        buffer.append("'")
        return buffer
    }
}


extension SQLBinary: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return self
    }
}