//
//  DisplayLinkAnimationView.swift
//  DisplayLinkAnimator
//
//  Created by Даниил Нуждин on 25.01.2018.
//  Copyright © 2018 vientooscuro. All rights reserved.
//

import UIKit

open class VoDisplayLinkAnimator {

    private var displayLink: CADisplayLink?
    private var startTime = 0.0
    private var animationDuration = 15.0
    public var preferredFramesPerSecond: Int = UIScreen.main.maximumFramesPerSecond {
        didSet {
            displayLink?.preferredFramesPerSecond = preferredFramesPerSecond
        }
    }

    private var bezierCurve: BezierCurve?

    public init() {

    }

    private func startDisplayLink() {
        self.isForceStopped.value = false
        startTime = CACurrentMediaTime() // reset start time

        // create displayLink & add it to the run-loop
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink.preferredFramesPerSecond = preferredFramesPerSecond
        displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
        self.displayLink = displayLink
    }

    private var completion: ((Bool) -> Void)?
    private var animation: ((_ x: Double, _ time: Double) -> Void)?
    private var timingFunction: ((_ x: Double, _ lastY: Double) -> Double)?
    public var isWorking: Bool {
        self.displayLink != nil
    }


    private let isPaused = AtomicValue(false)
    private let isForceStopped = AtomicValue(false)

    public var userData: Any?

    public func startBezierAnimation(animationDuration: Double = 0.25, animation: @escaping (_ time: Double) -> Void = {_ in }, bezierCurve: @escaping () -> BezierCurve, completion: @escaping (Bool) -> Void = { _ in }) {
        stopDisplayLink() // make sure to stop a previous running display link
        self.completion = completion
        self.animation = { x, progress in
            animation(progress)
        }
        self.animationDuration = animationDuration
        DispatchQueue.global(qos: .userInitiated).async {
            self.bezierCurve = bezierCurve()
            DispatchQueue.main.async {
                self.startDisplayLink()
            }
        }
    }

    private var needCompleteAnimationAfterStopping = false
    public func startAnimation(animationDuration: Double = 0.25, needCompleteAnimationAfterStopping: Bool = false, animation: @escaping (_ time: Double) -> Void = {_ in }, timingFunction: @escaping (_ x: Double, _ lastY: Double) -> Double = { x, _ in return x }, completion: @escaping (Bool) -> Void = { _ in }) {
        startAnimation(animationDuration: animationDuration, needCompleteAnimationAfterStopping: needCompleteAnimationAfterStopping, animation: {
            x, progress in
            animation(progress)
        }, timingFunction: timingFunction, completion: completion)
    }

    public func startAnimation(animationDuration: Double = 0.25, needCompleteAnimationAfterStopping: Bool = false, animation: @escaping (_ x: Double, _ time: Double) -> Void = {_,_  in }, timingFunction: @escaping (_ x: Double, _ lastY: Double) -> Double = { x, _ in return x }, completion: @escaping (Bool) -> Void = { _ in }) {
        stopDisplayLink() // make sure to stop a previous running display link
        self.completion = completion
        self.needCompleteAnimationAfterStopping = needCompleteAnimationAfterStopping
        self.timingFunction = timingFunction
        self.animation = animation
        self.animationDuration = animationDuration
        startDisplayLink()
    }

    public func stopAnimation() {
        if needCompleteAnimationAfterStopping {
            publish(progress: 1)
        }
        self.isForceStopped.value = true
        stopDisplayLink()
    }

    public var isAnimationPaused: Bool {
        isPaused.value
    }

    public func togglePauseAnimation() {
        isPaused.value.toggle()
    }

    public private(set) var elapsedTime: Double = 0

    private func publish(progress: Double) {
        let timingValue = if let bezierCurve {
            bezierCurve.y(of: progress)
        } else if let timingFunction {
            timingFunction(progress, lastTimingValue)
        } else {
            progress
        }
        animation?(elapsedTime, timingValue)
    }

    @objc private func displayLinkDidFire(_ displayLink: CADisplayLink) {
        guard !isPaused.value else {
            startTime = CACurrentMediaTime() - elapsedTime
            return
        }

        var elapsed = CACurrentMediaTime() - startTime
        elapsedTime = elapsed

        let progress = elapsed / animationDuration
        if elapsed > animationDuration {
            publish(progress: 1)
            stopDisplayLink()
            elapsed = animationDuration
            return
        }
        publish(progress: progress)
    }

    private var lastTimingValue: Double = 0

    func animationSucceededAction(completion: ((Bool) -> Void)? = nil) {
        if displayLink == nil { return }
        displayLink = nil
        let elapsed = CACurrentMediaTime() - startTime
        completion?(isForceStopped.value ? false : elapsed > animationDuration)
        isForceStopped.value = false
    }
    // invalidate display link if it's non-nil, then set to nil
    private func stopDisplayLink() {
        let completion = self.completion
        self.completion = nil
        timingFunction = nil
        timingFunction = nil
        animation = nil
        elapsedTime = 0
        if let displayLink {
            displayLink.invalidate()
            animationSucceededAction(completion: completion)
        }
    }

    deinit {
        stopDisplayLink()
    }
}

