//
//  Numeric.swift
//  DisplayLinkAnimator
//
//  Created by Daniil Nuzhdin on 06.01.2018.
//  Copyright © 2018 vientooscuro. All rights reserved.
//

import UIKit

public protocol Numeric: FloatingPoint {
    //
    init(_ v: Float)
    init(_ v: Double)
    init(_ v: Int)
    init(_ v: UInt)
    init(_ v: Int8)
    init(_ v: UInt8)
    init(_ v: Int16)
    init(_ v: UInt16)
    init(_ v: Int32)
    init(_ v: UInt32)
    init(_ v: Int64)
    init(_ v: UInt64)
    init(_ value: CGFloat)

    func _asOther<T: Numeric>() -> T
}

public extension Numeric {
    init<T: Numeric>(fromNumeric numeric: T) { self = numeric._asOther() }

    func convert<T: Numeric>() -> T {
        switch self {
        case let x as CGFloat:
            return T(x) //T.init(x)
        case let x as Float:
            return T(x)
        case let x as Double:
            return T(x)
        default:
            assert(false, "Numeric convert cast failed!")
            return T(0)
        }
    }
}

extension Float: Numeric {
    public func _asOther<T: Numeric>() -> T {
        T(self)
    }
}

extension Double: Numeric {
    public func _asOther<T: Numeric>() -> T {
        T(self)
    }
}

extension CGFloat: Numeric {
    public func _asOther<T: Numeric>() -> T {
        T(self)
    }
}

public extension CGFloat {
    init(_ value: CGFloat){
        self = value
    }
}

public enum RoundingRule {
    case up
    case down
    case nearest
}

public extension FloatingPoint {
    var radians: Self {
        self * Self.pi / 180
    }

    var degrees: Self {
        self * 180 / Self.pi
    }

    var sqr: Self {
        self * self
    }

    var squareRoot: Self {
        sqrt(self)
    }

    var sign: Self {
        self >= 0 ? 1 : -1
    }

    var floor: Self {
        self.rounded(.down)
    }

    var ceil: Self {
        self.rounded(.up)
    }

    func rounded(by scale: Self, roundingRule: RoundingRule = .nearest) -> Self {
        switch roundingRule {
        case .nearest:
            return (self * scale).rounded() / scale
        case .up:
            return (self * scale).rounded(.up) / scale
        case .down:
            return (self * scale).rounded(.down) / scale
        }
    }
}

public extension BinaryFloatingPoint {
    var roundValue: Int64 {
        Int64(self.rounded())
    }

    var cgf: CGFloat {
        CGFloat(self)
    }

    var timeInterval: TimeInterval {
        TimeInterval(self)
    }

    var int: Int {
        self.isNaN ? 0 : Int(self)
    }

    var double: Double {
        Double(self)
    }

    var float: Float {
        Float(self)
    }

    var kb: Self {
        self * 1024
    }

    var mb: Self {
        self.kb * 1024
    }

    var gb: Self {
        self.mb * 1024
    }

}

public func ===<T: FloatingPoint>(lhs: T, rhs: T) -> Bool {
    abs(lhs - rhs) < T.ulpOfOne
}

public func !==<T: FloatingPoint>(lhs: T, rhs: T) -> Bool {
    abs(lhs - rhs) > T.ulpOfOne
}
