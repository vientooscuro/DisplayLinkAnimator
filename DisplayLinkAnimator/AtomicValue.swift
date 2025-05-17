//
// Created by Daniil Nuzhdin on 2019-06-19.
// Copyright (c) 2019 vientooscuro. All rights reserved.
//

import Foundation

public func +=(lhs: AtomicValue<Int>, rhs: Int) {
    lhs.value += rhs
}

public func +=(lhs: AtomicValue<Int>, rhs: AtomicValue<Int>) {
    lhs.value += rhs.value
}

public func -=(lhs: AtomicValue<Int>, rhs: Int) {
    lhs.value += rhs
}

public func -=(lhs: AtomicValue<Int>, rhs: AtomicValue<Int>) {
    lhs.value += rhs.value
}

public final class AtomicValue<T> {
    private let accessQueue = DispatchQueue(label: "SynchronizedValueAccess", attributes: .concurrent)
    private var _value: T

    public init(_ value: T) {
        self._value = value
    }

    public var value: T {
        get {
            var currentValue: T?
            self.accessQueue.sync {
                currentValue = self._value
            }
            return currentValue!
        }
        set {
            self.accessQueue.async(flags: .barrier) {
                self._value = newValue
            }
        }
    }
}
