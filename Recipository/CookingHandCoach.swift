//
//  CookingHandCoach.swift
//  Recipository
//
//  On-device ARKit hand tracking with spoken + banner coaching. Starts only for
//  motion-relevant steps; stops cleanly when inactive or when leaving the recipe.
//

import ARKit
import AVFoundation
import Foundation
import Observation
import SwiftUI

/// Coordinates `HandTrackingProvider`, motion heuristics, and feedback. All processing is on-device.
@Observable
@MainActor
final class CookingHandCoach {
    private(set) var bannerMessage: String?
    /// True while an ARKit session is running for coaching (only on supported hardware with permission).
    private(set) var isHandTrackingActive: Bool = false

    private var motionKind: CookingMotionKind = .inactive
    private var stepStartedAt: Date?
    private var session: ARKitSession?
    private var trackingTask: Task<Void, Never>?
    private var analyzer = CookingHandMotionAnalyzer()
    private let synthesizer = AVSpeechSynthesizer()

    private var lastFeedbackAt: [String: Date] = [:]
    private let minFeedbackInterval: TimeInterval = 14
    private var bannerDismissTask: Task<Void, Never>?

    private var lastWristPitch: [HandAnchor.Chirality: Float] = [:]
    private var lastPitchTime: TimeInterval?

    private var emittedMixAlmostDone = false
    private var emittedMixOver = false

    /// Call when the visible recipe step changes.
    func update(stepText: String, stepIndex _: Int) {
        stopTrackingInternal()
        analyzer.reset()
        emittedMixAlmostDone = false
        emittedMixOver = false
        lastWristPitch.removeAll()
        lastPitchTime = nil
        lastFeedbackAt.removeAll()

        motionKind = CookingStepMotionProfile.parse(stepText)
        stepStartedAt = Date()

        switch motionKind {
        case .inactive:
            isHandTrackingActive = false
        default:
            guard HandTrackingProvider.isSupported else {
                isHandTrackingActive = false
                return
            }
            startTracking()
        }
    }

    /// Call when leaving the recipe screen.
    func stop() {
        stopTrackingInternal()
        motionKind = .inactive
        bannerDismissTask?.cancel()
        bannerMessage = nil
    }

    private func stopTrackingInternal() {
        trackingTask?.cancel()
        trackingTask = nil
        session?.stop()
        session = nil
        isHandTrackingActive = false
    }

    private func startTracking() {
        let session = ARKitSession()
        let provider = HandTrackingProvider()
        self.session = session
        self.isHandTrackingActive = true

        trackingTask = Task { [weak self] in
            guard let self else { return }
            do {
                let auth = await session.requestAuthorization(for: [.handTracking])
                guard auth[.handTracking] == .allowed else {
                    await MainActor.run { self.isHandTrackingActive = false }
                    return
                }
                try await session.run([provider])
                for await update in provider.anchorUpdates {
                    if Task.isCancelled { break }
                    guard update.event != .removed else { continue }
                    let anchor = update.anchor
                    guard anchor.isTracked else { continue }
                    await MainActor.run {
                        self.process(anchor: anchor, timestamp: update.timestamp)
                    }
                }
            } catch {
                await MainActor.run { self.isHandTrackingActive = false }
            }
        }
    }

    private func process(anchor: HandAnchor, timestamp: TimeInterval) {
        guard motionKind != .inactive else { return }

        if let pos = HandPoseMath.worldPosition(hand: anchor, jointName: .wrist) {
            switch anchor.chirality {
            case .left:
                analyzer.recordLeftWrist(time: timestamp, position: pos)
            case .right:
                analyzer.recordRightWrist(time: timestamp, position: pos)
            }
        }

        if motionKind == .pouring,
           let skeleton = anchor.handSkeleton {
            let joint = skeleton.joint(.wrist)
            if joint.isTracked {
                let m = anchor.originFromAnchorTransform * joint.anchorFromJointTransform
                let pitch = HandPoseMath.wristPitchRadians(m)
                if let last = lastWristPitch[anchor.chirality], let pt = lastPitchTime {
                    let dt = timestamp - pt
                    if dt > 0.008 {
                        let rate = abs(pitch - last) / Float(dt)
                        if rate > 2.8 {
                            maybeEmit(key: "pourTilt", message: "Try tilting and pouring a little more slowly for better control.")
                        }
                    }
                }
                lastWristPitch[anchor.chirality] = pitch
                lastPitchTime = timestamp
            }
        }

        evaluateHeuristics(at: timestamp)
    }

    private func evaluateHeuristics(at timestamp: TimeInterval) {
        let speed = analyzer.meanHorizontalSpeed(at: timestamp)
        let idle = analyzer.idleDurationHorizontal(at: timestamp, speedThreshold: 0.028)
        let jitter = analyzer.speedJitter(at: timestamp)
        let vSpeed = analyzer.maxVerticalSpeed(at: timestamp)
        let rev = analyzer.directionReversalsInLast12s()

        switch motionKind {
        case .inactive:
            break

        case let .mixing(targetDuration):
            if speed < 0.038, idle > 5 {
                maybeEmit(key: "mixIdle", message: "Keep the mixture moving steadily so everything combines evenly.")
            }
            if speed > 0.95 {
                maybeEmit(key: "mixFast", message: "You may be mixing quickly; slow down a bit if the recipe needs a gentle touch.")
            }
            if rev > 5 {
                maybeEmit(key: "mixReverse", message: "Try to keep a consistent stir direction so delicate batters stay light.")
            }
            if let target = targetDuration, let start = stepStartedAt {
                let elapsed = Date().timeIntervalSince(start)
                if !emittedMixAlmostDone, elapsed >= max(target - 22, 0), elapsed < target {
                    emittedMixAlmostDone = true
                    maybeEmit(key: "mixAlmost", message: "You are getting close to the suggested mixing time for this step.", force: true)
                }
                if !emittedMixOver, elapsed >= target {
                    emittedMixOver = true
                    maybeEmit(key: "mixStop", message: "Time is up for mixing; stop before you overwork the mixture.", force: true)
                }
            }

        case .kneading:
            if speed < 0.045, idle > 4.2 {
                maybeEmit(key: "kneadIdle", message: "Keep kneading with steady folds and pushes until the dough feels right.")
            }

        case .pouring:
            if vSpeed > 0.42 {
                maybeEmit(key: "pourDrop", message: "Try to pour a little more slowly when precision matters.")
            }

        case .chopping:
            if jitter > 1.45 {
                maybeEmit(key: "chopErratic", message: "Your cutting rhythm looks a bit rushed. Slow down and tuck your fingertips.")
            }
            if let sep = analyzer.wristSeparation(), sep < 0.11 {
                maybeEmit(key: "handsClose", message: "Give your hands a bit more space on the board for safer cuts.")
            }

        case .generalActive:
            if speed < 0.035, idle > 6 {
                maybeEmit(key: "activeIdle", message: "Whenever you are ready, continue this step with steady motion.")
            }
        }
    }

    private func maybeEmit(key: String, message: String, force: Bool = false) {
        let now = Date()
        if !force, let last = lastFeedbackAt[key], now.timeIntervalSince(last) < minFeedbackInterval {
            return
        }
        lastFeedbackAt[key] = now
        speak(message)
        showBanner(message)
    }

    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        synthesizer.speak(utterance)
    }

    private func showBanner(_ text: String) {
        bannerDismissTask?.cancel()
        bannerMessage = text
        bannerDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(4.5))
            guard let self, !Task.isCancelled else { return }
            await MainActor.run {
                self.bannerMessage = nil
            }
        }
    }
}
