//
//  Sync.swift
//  MySQL
//
//  Created by Yusuke Ito on 1/12/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//

#if os(Linux)
    import Glibc
#elseif os(OSX)
    import Darwin.C
#endif

fileprivate final class Mutex {
    private var mutex = pthread_mutex_t()
    init() {
        pthread_mutex_init(&mutex, nil)
    }
    
    func lock() {
        pthread_mutex_lock(&mutex)
    }
    
    func unlock() {
        pthread_mutex_unlock(&mutex)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
}

internal struct Atomic<T> {
    private var value: T
    private let mutex = Mutex()
    init(_ value: T) {
        self.value = value
    }
    mutating func syncWriting<R>( _ block: (inout T) throws -> R) rethrows -> R {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        let result = try block(&value)
        return result
    }
    
    func sync<R>( _ block: (T) throws -> R) rethrows -> R {
        mutex.lock()
        defer {
            mutex.unlock()
        }
        let result = try block(value)
        return result
    }
}
