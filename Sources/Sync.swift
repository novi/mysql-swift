//
//  Sync.swift
//  MySQL
//
//  Created by Yusuke Ito on 1/12/16.
//  Copyright © 2016 Yusuke Ito. All rights reserved.
//



final class Mutex {
    var mutex = pthread_mutex_t()
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

extension Mutex {
    
    func sync<T>(@noescape block: () -> T) -> T {
        lock()
        let result = block()
        unlock()
        return result
    }
    
}