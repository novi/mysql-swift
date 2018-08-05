//
//  Blob.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/22/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

import Foundation
import SQLFormatter

extension Data: SQLRawStringDecodable {
    public static func fromSQLValue(string: String) throws -> Data {
        fatalError("logic error, construct via init(:)")
    }
}

fileprivate let HexTable: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]

extension Data: QueryParameterType {
    public func escaped() -> String {
        var buffer = [Character](["x", "'"])
        buffer.reserveCapacity( self.count * 2 + 3 ) // 3 stands for "x''", 2 stands for 2 characters per a byte data
        for byte in self {
            buffer.append(HexTable[Int((byte >> 4) & 0x0f)])
            buffer.append(HexTable[Int(byte & 0x0f)])
        }
        buffer.append("'")
        return String(buffer)
    }
    
    public func escapedForID() -> String? {
        return nil // Data can not be used for ID(?? placeholder).
    }
}

extension Data: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return self
    }
}

internal struct Blob: QueryParameter {
    let data: Data
    let dataType: QueryCustomDataParameterDataType
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return self
    }
}

extension Blob: QueryParameterType {
    public func escaped() -> String {
        switch dataType {
        case .blob: return data.escaped()
        case .json:
            return "CONVERT(" + data.escaped() + " using utf8mb4)"
        }
    }
    
    public func escapedForID() -> String? {
        return nil // Data can not be used for ID(?? placeholder).
    }
}

