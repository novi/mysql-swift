//
//  Builder-Parameter.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public func buildParam<A: QueryArgumentValueType>(p: (A) ) -> [QueryArgumentValueType] {
    return [
        p
    ]
}

public func buildParam<A: QueryArgumentValueType, B: QueryArgumentValueType>(p: (A, B) ) -> [QueryArgumentValueType] {
    return [
        p.0,
        p.1
    ]
}

public func buildParam<A: QueryArgumentValueType, B: QueryArgumentValueType, C: QueryArgumentValueType>(p: (A, B, C) ) -> [QueryArgumentValueType] {
    return [
        p.0,
        p.1,
        p.2
    ]
}

public func buildParam<A: QueryArgumentValueType, B: QueryArgumentValueType, C: QueryArgumentValueType, D: QueryArgumentValueType>(p: (A, B, C, D) ) -> [QueryArgumentValueType] {
    return [
        p.0,
        p.1,
        p.2,
        p.3
    ]
}

public func buildParam<A: QueryArgumentValueType, B: QueryArgumentValueType, C: QueryArgumentValueType, D: QueryArgumentValueType, E: QueryArgumentValueType>(p: (A, B, C, D, E) ) -> [QueryArgumentValueType] {
    return [
        p.0,
        p.1,
        p.2,
        p.3,
        p.4
    ]
}

public func buildParam<A: QueryArgumentValueType, B: QueryArgumentValueType, C: QueryArgumentValueType, D: QueryArgumentValueType, E: QueryArgumentValueType, F: QueryArgumentValueType>(p: (A, B, C, D, E, F) ) -> [QueryArgumentValueType] {
    return [
        p.0,
        p.1,
        p.2,
        p.3,
        p.4,
        p.5
    ]
}