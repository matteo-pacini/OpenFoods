//
//  DependencyInjection.swift
//  OpenFoods
//
//  Created by Matteo Pacini on 03/05/2024.
//  Copyright © 2024 OpenTable, Inc. All rights reserved.
//

import Foundation
import Swinject

/// Main dependency container
var dependencyContainer = Container()

@propertyWrapper
struct Injected<Value> {

    init(name: String? = nil) {
        wrappedValue = dependencyContainer.resolve(Value.self, name: name)!
    }

    let wrappedValue: Value

}

@propertyWrapper
struct LazyInjected<Value> {

    private let name: String?
    private var service: Value!
    private let lock = NSLock()

    init(name: String? = nil) {
        self.name = name
    }

    var wrappedValue: Value {
        mutating get {
            lock.lock()
            defer { lock.unlock() }
            if service == nil {
                service = dependencyContainer.resolve(Value.self)
            }
            return service
        }
    }

}
