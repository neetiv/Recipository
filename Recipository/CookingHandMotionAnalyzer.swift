//
//  CookingHandMotionAnalyzer.swift
//  Recipository
//
//  Heuristic metrics from wrist motion over time (ARKit world-space joints).
//

import ARKit
import Foundation
import simd

struct HandSample {
    var time: TimeInterval
    var position: SIMD3<Float>
}

/// Accumulates wrist samples and derives coarse motion cues. Values are heuristics, not calibrated kitchen instruments.
struct CookingHandMotionAnalyzer {
    private var leftSamples: [HandSample] = []
    private var rightSamples: [HandSample] = []
    private var lastAngleLeft: Float?
    private var lastAngleRight: Float?
    private var directionFlipTimestamps: [TimeInterval] = []

    private let historySeconds: TimeInterval = 3.0
    private let maxSamples = 120

    mutating func reset() {
        leftSamples.removeAll(keepingCapacity: false)
        rightSamples.removeAll(keepingCapacity: false)
        lastAngleLeft = nil
        lastAngleRight = nil
        directionFlipTimestamps.removeAll(keepingCapacity: false)
    }

    mutating func recordLeftWrist(time: TimeInterval, position: SIMD3<Float>) {
        var buffer = leftSamples
        buffer.append(HandSample(time: time, position: position))
        pruneBuffer(&buffer, now: time)
        if buffer.count > maxSamples {
            buffer.removeFirst(buffer.count - maxSamples)
        }
        leftSamples = buffer
        recordDirectionFlips(samples: leftSamples, time: time, newPos: position, isLeft: true)
    }

    mutating func recordRightWrist(time: TimeInterval, position: SIMD3<Float>) {
        var buffer = rightSamples
        buffer.append(HandSample(time: time, position: position))
        pruneBuffer(&buffer, now: time)
        if buffer.count > maxSamples {
            buffer.removeFirst(buffer.count - maxSamples)
        }
        rightSamples = buffer
        recordDirectionFlips(samples: rightSamples, time: time, newPos: position, isLeft: false)
    }

    private func pruneBuffer(_ buffer: inout [HandSample], now: TimeInterval) {
        let cutoff = now - historySeconds
        buffer.removeAll { $0.time < cutoff }
    }

    /// Horizontal-plane motion angle rate; large flips may indicate reversing stir direction often.
    private mutating func recordDirectionFlips(samples: [HandSample], time: TimeInterval, newPos: SIMD3<Float>, isLeft: Bool) {
        guard samples.count >= 2 else { return }
        let prev = samples[samples.count - 2].position
        let v = SIMD3<Float>(newPos.x - prev.x, 0, newPos.z - prev.z)
        let speed = simd_length(v)
        guard speed > 0.015 else { return }

        let angle = atan2(v.z, v.x)
        let last = isLeft ? lastAngleLeft : lastAngleRight
        if let last {
            var delta = angle - last
            while delta > .pi { delta -= 2 * .pi }
            while delta < -.pi { delta += 2 * .pi }
            if abs(delta) > 2.2 {
                directionFlipTimestamps.append(time)
            }
        }
        if isLeft {
            lastAngleLeft = angle
        } else {
            lastAngleRight = angle
        }
        let cutoff = time - 12
        directionFlipTimestamps.removeAll { $0 < cutoff }
    }

    func meanHorizontalSpeed(at time: TimeInterval) -> Float {
        max(meanSpeed2D(samples: leftSamples, at: time), meanSpeed2D(samples: rightSamples, at: time))
    }

    private func meanSpeed2D(samples: [HandSample], at time: TimeInterval) -> Float {
        guard samples.count >= 2 else { return 0 }
        let window: TimeInterval = 1.2
        let start = time - window
        var total: Float = 0
        var count = 0
        for i in 1..<samples.count {
            let a = samples[i - 1]
            let b = samples[i]
            guard b.time >= start else { continue }
            let dt = Float(b.time - a.time)
            guard dt > 1e-4 else { continue }
            let p0 = SIMD3<Float>(a.position.x, 0, a.position.z)
            let p1 = SIMD3<Float>(b.position.x, 0, b.position.z)
            total += simd_length(p1 - p0) / dt
            count += 1
        }
        return count > 0 ? total / Float(count) : 0
    }

    /// Coefficient of variation of speed — high suggests erratic motion.
    func speedJitter(at time: TimeInterval) -> Float {
        let lj = jitter(samples: leftSamples, at: time)
        let rj = jitter(samples: rightSamples, at: time)
        return max(lj, rj)
    }

    private func jitter(samples: [HandSample], at time: TimeInterval) -> Float {
        guard samples.count >= 4 else { return 0 }
        let window: TimeInterval = 0.9
        let start = time - window
        var speeds: [Float] = []
        for i in 1..<samples.count {
            let a = samples[i - 1]
            let b = samples[i]
            guard b.time >= start else { continue }
            let dt = Float(b.time - a.time)
            guard dt > 1e-4 else { continue }
            let p0 = SIMD3<Float>(a.position.x, 0, a.position.z)
            let p1 = SIMD3<Float>(b.position.x, 0, b.position.z)
            speeds.append(simd_length(p1 - p0) / dt)
        }
        guard speeds.count >= 3 else { return 0 }
        let mean = speeds.reduce(0, +) / Float(speeds.count)
        guard mean > 1e-3 else { return 0 }
        let varSum = speeds.map { pow($0 - mean, 2) }.reduce(0, +)
        let sd = sqrt(varSum / Float(speeds.count))
        return sd / mean
    }

    func idleDurationHorizontal(at time: TimeInterval, speedThreshold: Float) -> TimeInterval {
        let l = idleSince(samples: leftSamples, at: time, threshold: speedThreshold)
        let r = idleSince(samples: rightSamples, at: time, threshold: speedThreshold)
        return max(l, r)
    }

    private func idleSince(samples: [HandSample], at time: TimeInterval, threshold: Float) -> TimeInterval {
        guard let last = samples.last else { return 0 }
        var t = last.time
        var i = samples.count - 1
        while i > 0 {
            let dt = Float(samples[i].time - samples[i - 1].time)
            guard dt > 1e-4 else { i -= 1; continue }
            let p0 = SIMD3<Float>(samples[i - 1].position.x, 0, samples[i - 1].position.z)
            let p1 = SIMD3<Float>(samples[i].position.x, 0, samples[i].position.z)
            let spd = simd_length(p1 - p0) / dt
            if spd > threshold {
                t = samples[i].time
                break
            }
            i -= 1
        }
        return time - t
    }

    func wristSeparation() -> Float? {
        guard let l = leftSamples.last, let r = rightSamples.last else { return nil }
        return simd_length(l.position - r.position)
    }

    func directionReversalsInLast12s() -> Int {
        directionFlipTimestamps.count
    }

    /// Vertical velocity magnitude — rough cue for fast tilting / pouring.
    func maxVerticalSpeed(at time: TimeInterval) -> Float {
        max(verticalSpeed(samples: leftSamples, at: time), verticalSpeed(samples: rightSamples, at: time))
    }

    private func verticalSpeed(samples: [HandSample], at time: TimeInterval) -> Float {
        guard samples.count >= 2 else { return 0 }
        let window: TimeInterval = 0.45
        let start = time - window
        var peak: Float = 0
        for i in 1..<samples.count {
            let a = samples[i - 1]
            let b = samples[i]
            guard b.time >= start else { continue }
            let dt = Float(b.time - a.time)
            guard dt > 1e-4 else { continue }
            let dv = abs(b.position.y - a.position.y) / dt
            peak = max(peak, dv)
        }
        return peak
    }
}

enum HandPoseMath {
    static func worldPosition(hand: HandAnchor, jointName: HandSkeleton.JointName) -> SIMD3<Float>? {
        guard let skeleton = hand.handSkeleton else { return nil }
        let joint = skeleton.joint(jointName)
        guard joint.isTracked else { return nil }
        let m = hand.originFromAnchorTransform * joint.anchorFromJointTransform
        return SIMD3<Float>(m.columns.3.x, m.columns.3.y, m.columns.3.z)
    }

    /// Approximate wrist pitch from rotation (radians), useful for pour-rate heuristics.
    static func wristPitchRadians(_ m: simd_float4x4) -> Float {
        let r2 = m.columns.2
        let sinPitch = simd_clamp(-r2.y, -1, 1)
        return asin(sinPitch)
    }
}
