//
//  Builder-Parameter.swift
//  MySQL
//
//  Created by ito on 12/20/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

public func build<A: QueryParameter>(_ p: (A) ) -> [QueryParameter] {
    return [
        p
    ]
}

public func build<A: QueryParameter, B: QueryParameter>(_ p: (A, B) ) -> [QueryParameter] {
    return [
        p.0,
        p.1
    ]
}

public func build<A: QueryParameter, B: QueryParameter, C: QueryParameter>(_ p: (A, B, C) ) -> [QueryParameter] {
    return [
        p.0,
        p.1,
        p.2
    ]
}

public func build<A: QueryParameter, B: QueryParameter, C: QueryParameter, D: QueryParameter>(_ p: (A, B, C, D) ) -> [QueryParameter] {
    return [
        p.0,
        p.1,
        p.2,
        p.3
    ]
}

public func build<A: QueryParameter, B: QueryParameter, C: QueryParameter, D: QueryParameter, E: QueryParameter>(_ p: (A, B, C, D, E) ) -> [QueryParameter] {
    return [
        p.0,
        p.1,
        p.2,
        p.3,
        p.4
    ]
}

public func build<A: QueryParameter, B: QueryParameter, C: QueryParameter, D: QueryParameter, E: QueryParameter, F: QueryParameter>(_ p: (A, B, C, D, E, F) ) -> [QueryParameter] {
    return [
        p.0,
        p.1,
        p.2,
        p.3,
        p.4,
        p.5
    ]
}

public func build<A: QueryParameter, B: QueryParameter, C: QueryParameter, D: QueryParameter, E: QueryParameter, F: QueryParameter, G: QueryParameter>(_ p: (A, B, C, D, E, F, G) ) -> [QueryParameter] {
    return [
        p.0,
        p.1,
        p.2,
        p.3,
        p.4,
        p.5,
        p.6
    ]
}