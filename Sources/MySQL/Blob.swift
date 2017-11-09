//
//  Blob.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/22/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import Foundation
import SQLFormatter

@available(*, deprecated)
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
    
    init(_ data: Data) {
        self.init(Array(data))
    }
    
    fileprivate var nsData: Data {
        return Data(bytes: unsafeBitCast(buffer, to: [UInt8].self))
    }
}

// for (NS)Data


extension Data: SQLStringDecodable {
    public static func fromSQL(string: String) throws -> Data {
        fatalError("construct via init(:)")
    }
}

extension Data: QueryParameterType {
    public func escaped() -> String {
        var buffer = "x'"
        for d in self {
            let str = String(d, radix: 16)
            if str.count == 1 {
                buffer.append("0")
            }
            buffer += str
        }
        buffer += "'"
        return buffer
    }
}

extension Data: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return self
    }
}

