//
//  Builder.swift
//  MySQL
//
//  Created by ito on 12/10/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public func build<A, B, C, Value>(create: (A, B, C) -> Value)(_ a: A, _ b: B, _ c: C) -> Value {
    return create(a, b, c)
}

public func build<A, B, C, D, Value>(create: (A, B, C, D) -> Value)(_ a: A, _ b: B, _ c: C, _ d: D) -> Value {
    return create(a, b, c, d)
}
