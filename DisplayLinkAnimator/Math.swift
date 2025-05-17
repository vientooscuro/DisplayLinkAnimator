//
//  Math.swift
//  DisplayLinkAnimator
//
//  Created by Daniil Nuzhdin on 23.01.2018.
//  Copyright © 2018 vientooscuro. All rights reserved.
//

import CoreGraphics

public class Math {
    public struct Complex {
        public var x: CGFloat
        public var y: CGFloat

        public init() {
            self.x = 0
            self.y = 0
        }
    }

    public static func cubicSolve(a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat) -> (Complex, Complex, Complex)
    {
        var complex1 = Complex(), complex2 = Complex(), complex3 = Complex()
        let PI = CGFloat.pi
        let b = b / a
        let c = c / a
        let d = d / a
        var disc: CGFloat, q: CGFloat, r: CGFloat, dum1: CGFloat, s: CGFloat, t: CGFloat, term1: CGFloat, r13: CGFloat
        q = (3.0*c - (b*b))/9.0
        r = -(27.0*d) + b*(9.0*c - 2.0*(b*b))
        r /= 54.0
        disc = q*q*q + r*r
        var x1Re: CGFloat = 0
        var x3Re: CGFloat = 0
        var x2Im: CGFloat = 0
        var x3Im: CGFloat = 0
        var x2Re: CGFloat = 0
        let x1Im: CGFloat = 0 //The first root is always real.
        term1 = b / 3.0
        if disc > 0 { // one root real, two are complex
            s = r + disc.squareRoot
            s = ((s < 0) ? -pow(-s, (1.0/3.0)) : pow(s, (1.0/3.0)))
            t = r - disc.squareRoot
            t = ((t < 0) ? -pow(-t, (1.0/3.0)) : pow(t, (1.0/3.0)))
            x1Re = -term1 + s + t
            term1 += (s + t)/2.0
            x3Re = -term1
            x2Re = -term1
            let squareOf3: CGFloat = sqrt(3.0)
            let sMinusT = (s - t) / 2
            term1 = squareOf3 * sMinusT
            x2Im = term1
            x3Im = -term1

            complex1.x = x1Re
            complex1.y = x1Im
            complex2.x = x2Re
            complex2.y = x2Im
            complex3.x = x3Re
            complex3.y = x3Im
            return (complex1, complex2, complex3)
        }
        // End if (disc > 0)
        // The remaining options are all real
        x3Im = 0
        x2Im = 0
        if (disc == 0){ // All roots real, at least two are equal.
            r13 = ((r < 0) ? -pow(-r,(1.0/3.0)) : pow(r,(1.0/3.0)))
            x1Re = -term1 + 2.0*r13
            x3Re = -(r13 + term1)
            x2Re = -(r13 + term1)

            complex1.x = x1Re
            complex1.y = x1Im
            complex2.x = x2Re
            complex2.y = x2Im
            complex3.x = x3Re
            complex3.y = x3Im
            return (complex1, complex2, complex3)
        } // End if (disc == 0)
        // Only option left is that all roots are real and unequal (to get here, q < 0)
        q = -q
        dum1 = q*q*q
        dum1 = acos(r/sqrt(dum1))
        r13 = 2.0*sqrt(q)
        x1Re = -term1 + r13*cos(dum1/3.0)
        x2Re = -term1 + r13*cos((dum1 + 2.0*PI)/3.0)
        x3Re = -term1 + r13*cos((dum1 + 4.0*PI)/3.0)

        complex1.x = x1Re
        complex1.y = x1Im
        complex2.x = x2Re
        complex2.y = x2Im
        complex3.x = x3Re
        complex3.y = x3Im
        return (complex1, complex2, complex3)
    }

    public static func cubicBezierPath<T: Numeric>(t: T, startPoint: CGPoint = .zero, cPoint1: CGPoint, cPoint2: CGPoint, endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> (x: T, y: T) {
        func value(a0: CGFloat, a1: CGFloat, a2: CGFloat, a3: CGFloat) -> T {
             let doubleT: Double = t.convert()
            let oneMinusTSqr = (1 - doubleT).sqr
            return (oneMinusTSqr * (1 - doubleT) * Double(a0) + 3 * doubleT * oneMinusTSqr * Double(a1) + 3 * doubleT.sqr * (1 - doubleT) * Double(a2) * doubleT.sqr * doubleT * Double(a3)).convert()
        }

        let x = value(a0: startPoint.x, a1: cPoint1.x, a2: cPoint2.x, a3: endPoint.x)
        let y = value(a0: startPoint.y, a1: cPoint1.y, a2: cPoint2.y, a3: endPoint.y)
        return (x: x, y: y)
    }

    private static func findValue(t: CGFloat, startPoint: CGPoint = .zero, cPoint1: CGPoint, cPoint2: CGPoint, endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> CGFloat {
        let firstPart = (1 - t) * (1 - t).sqr * startPoint.y
        let secondPart = 3 * t * (1 - t).sqr * cPoint1.y
        let thirdPart = 3 * t.sqr * (1 - t) * cPoint2.y
        let fourthPart = t * t.sqr * endPoint.y
        return firstPart + secondPart + thirdPart + fourthPart
    }

    private static func bezierPathValueIfYIsNaN<T: Numeric>(x xValue: T, startPoint: CGPoint = .zero, cPoint1: CGPoint, cPoint2: CGPoint, endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> T {
        let x: CGFloat = xValue.convert()

        let result = Math.cubicSolve(a: 3 * (cPoint1.x - cPoint2.x) + 1, b: 3 * cPoint2.x - 6 * cPoint1.x, c: 3 * cPoint1.x, d: -x+0.001)
        let result1 = Math.cubicSolve(a: 3 * (cPoint1.x - cPoint2.x) + 1, b: 3 * cPoint2.x - 6 * cPoint1.x, c: 3 * cPoint1.x, d: -x)

        //    if result.0.x >= -1 && result.0.x <= 1 {
        var t = result.0.x
        var t1 = result1.0.x
        var tmp = findValue(t: t, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
        let firstResult = findValue(t: t1, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
        var secondResult: CGFloat = 0
        var thirdResult: CGFloat = 0
        let firstDiff = (tmp < firstResult || firstResult - 1 > 0)  && firstResult >= 0 ? abs(tmp - firstResult) : CGFloat.greatestFiniteMagnitude

        var secondDiff = CGFloat.greatestFiniteMagnitude
        if abs(result.1.y) < 1e-4 && abs(result1.1.y) < 1e-4 {
            t = result.1.x
            t1 = result.1.x

            tmp = findValue(t: t, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
            secondResult = findValue(t: t1, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
            if (tmp < secondResult || secondResult - 1 > 0)  && secondResult >= 0 {
                secondDiff = abs(tmp - secondResult)
            }
        }

        var thirdDiff = CGFloat.greatestFiniteMagnitude
        if abs(result.2.y) < 1e-4 && abs(result1.2.y) < 1e-4 {
            t = result.2.x
            t1 = result.2.x

            tmp = findValue(t: t, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
            thirdResult = findValue(t: t1, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
            if tmp < thirdResult || thirdResult - 1 > 0 && thirdResult >= 0 {
                thirdDiff = abs(tmp - thirdResult)
            }
        }

        if firstDiff < secondDiff {
            if firstDiff < thirdDiff {
                return firstResult.convert()
            } else {
                return thirdResult.convert()
            }
        } else {
            if secondDiff < thirdDiff {
                return secondResult.convert()
            } else {
                return thirdResult.convert()
            }
        }
    }

    public static func bezierPathValue<T: Numeric>(x xValue: T, lastY yValue: T = .nan, startPoint: CGPoint = .zero, cPoint1: CGPoint, cPoint2: CGPoint, endPoint: CGPoint = CGPoint(x: 1, y: 1)) -> T {
        if yValue.isNaN {
           return bezierPathValueIfYIsNaN(x: xValue, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
        } else {
            let lastY: CGFloat = yValue.convert()
            let x: CGFloat = xValue.convert()
            let result = Math.cubicSolve(a: 3 * (cPoint1.x - cPoint2.x) - startPoint.x + endPoint.x, b: 3 * cPoint2.x - 6 * cPoint1.x + 3 * startPoint.x, c: 3 * (cPoint1.x - startPoint.x), d: startPoint.x - x)

            //    if result.0.x >= -1 && result.0.x <= 1 {
            var t = result.0.x
            let firstResult = findValue(t: t, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
            var secondResult: CGFloat = 0
            var thirdResult: CGFloat = 0
            let firstDiff = abs(lastY - firstResult)

            var secondDiff = CGFloat.greatestFiniteMagnitude
            if abs(result.1.y) < 1e-4 {
                t = result.1.x

                secondResult = findValue(t: t, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
                //                if secondResult >= 0 {
                secondDiff = abs(lastY - secondResult)
                //                }
            }

            var thirdDiff = CGFloat.greatestFiniteMagnitude
            if abs(result.2.y) < 1e-4 {
                t = result.2.x
                thirdResult = findValue(t: t, startPoint: startPoint, cPoint1: cPoint1, cPoint2: cPoint2, endPoint: endPoint)
                //                if thirdResult >= 0 {
                thirdDiff = abs(lastY - thirdResult)
                //                }
            }
            let res: CGFloat
            if firstDiff < secondDiff {
                if firstDiff < thirdDiff {
                    res = firstResult
                } else {
                    res = thirdResult
                }
            } else {
                if secondDiff < thirdDiff {
                    res = secondResult
                } else {
                    res = thirdResult
                }
            }
            return res.convert()
        }
    }

    public static func linearFunction<T: FloatingPoint>(x: T, left: T = 0, right: T = 1, leftValue: T, rightValue: T) -> T {
        let k = (rightValue - leftValue) / (right - left)
        let b = rightValue - k * right
        let res = k * (x.isNaN ? 1 : x) + b
        if res.isFinite {
            return res
        }
        print("unexpected state")
        return 0
    }

    public static func linearFunctionSolver<T: FloatingPoint>(left: T = 0, right: T = 1, leftValue: T, rightValue: T, value: T) -> T {
        let k = (rightValue - leftValue) / (right - left)
        let b = rightValue - k * right
        let res = (value - b) / k
        if res.isFinite {
            return res
        }
        print("unexpected state")
        return 0
    }

    public static func quadraticFunction<T: FloatingPoint>(x: T, x0: T = 0, x1: T = 1, minValue: T) -> T {
        let a = (x0 + x1) / 2 / minValue
        return a * (x - x0) * (x -  x1)
    }
}


