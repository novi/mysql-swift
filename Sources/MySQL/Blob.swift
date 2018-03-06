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
    public func escapedForID() -> String? {
        return nil
    }
}

extension Data: QueryParameter {
    public func queryParameter(option: QueryParameterOption) throws -> QueryParameterType {
        return self
    }
}

