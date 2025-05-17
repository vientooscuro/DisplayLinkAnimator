//
//  BezierCurve.swift
//  DisplayLinkAnimator
//
//  Created by Daniil Nuzhdin on 31.03.2018.
//  Copyright © 2018 vientooscuro. All rights reserved.
//

import Foundation

public struct VoPoint {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public init() {
        self.x = 0
        self.y = 0
    }
}

public class BezierCurve {

    private var curvePoints: [VoPoint]?

    public init(controlPoints: [VoPoint], pointsCount: Int) {
        solve(controlPoints: controlPoints, pointsCount: pointsCount)
    }

    public init(controlPoints: [VoPoint], pointsCount: Int, completionComputation: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.solve(controlPoints: controlPoints, pointsCount: pointsCount)
            DispatchQueue.main.async {
                completionComputation()
            }
        }
    }

    private func binarySearch(curvePoints: [VoPoint], x: Double, left: Int, right: Int) -> Double {
        var low = left
        var high = right

        while low < high {
            let mid = (low + high) / 2
            let d1 = abs(curvePoints[mid  ].x - x)
            let d2 = abs(curvePoints[mid + 1].x - x)
            if d2 <= d1 {
                low = mid + 1
            }
            else {
                high = mid
            }
        }
        if high == 0 {
            return curvePoints[high].y
        } else {
            return Math.linearFunction(x: x, left: curvePoints[high - 1].x, right: curvePoints[high].x, leftValue: curvePoints[high - 1].y, rightValue: curvePoints[high].y)
        }
    }

    public func y(of x: Double) -> Double {
        guard let curvePoints = self.curvePoints else { return 0 }
        return binarySearch(curvePoints: curvePoints, x: x, left: 0, right: curvePoints.count - 1)
    }

    private func c(n: Int, k: Int) -> Int {
        if k == 0 {
            return 1
        }
        if k > n / 2 {
            return c(n: n, k: n - k)
        }
        return n * c(n: n - 1, k: k - 1) / k
    }

    private func solve(controlPoints: [VoPoint], pointsCount: Int) {
        guard controlPoints.count > 2, pointsCount > 2 else { return }
        let coefficients = (0..<controlPoints.count).map { Double(self.c(n: controlPoints.count - 1, k: $0)) }
        func value(of t: Double) -> VoPoint {
            var x_t = 0.0
            var y_t = 0.0
            var t_powers = [1.0]
            var one_t_powers = [1.0]
            for _ in 1..<controlPoints.count {
                t_powers += t_powers[t_powers.count - 1] * t
                one_t_powers += one_t_powers[one_t_powers.count - 1] * (1 - t)
            }
            for i in 0..<controlPoints.count {
                let point = controlPoints[i]
                x_t += Double(point.x) * t_powers[controlPoints.count - i - 1] * one_t_powers[i] * coefficients[i]
                y_t += Double(point.y) * t_powers[controlPoints.count - i - 1] * one_t_powers[i] * coefficients[i]
            }
            return VoPoint(x: x_t, y: y_t)
        }

        let step = 1 / Double(pointsCount)
        var t = 0.0
        var curvePoints = [VoPoint]()
        for _ in 0..<pointsCount - 1 {
            curvePoints += value(of: t)
            t += step
        }

        curvePoints += value(of: 1)
        self.curvePoints = curvePoints
    }
}
