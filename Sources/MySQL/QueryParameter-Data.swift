//
//  QueryParameter-Data.swift
//  MySQL
//
//  Created by Yusuke Ito on 4/29/18.
//

import Foundation

public protocol QueryRowResultCustomData {
    static func decode(fromRowData data: Data) throws -> Self
}

public protocol QueryCustomDataParameter {
    func encodeForQueryParameter() throws -> Data
}

