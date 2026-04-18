//
//  TimerManager.swift
//  Recipository
//
//  Created by iguest on 4/18/26.
//


import SwiftUI
import Combine
import AVFoundation

@MainActor
class TimerManager: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isTimerActive = false
    @Published var hasTimer = false
    
    private var timer: AnyCancellable?
    private var audioPlayer: AVAudioPlayer?

    // Parses strings like "Bake for 20 minutes" or "Let sit for 30 seconds"
    func determineTime(from step: String) {
        let lowerStep = step.lowercased()
        let pattern = #"(\d+)\s*(minute|min|second|sec)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: lowerStep, range: NSRange(lowerStep.startIndex..., in: lowerStep)) else {
            self.hasTimer = false
            return
        }

        let amount = Double((lowerStep as NSString).substring(with: match.range(at: 1))) ?? 0
        let unit = (lowerStep as NSString).substring(with: match.range(at: 2))

        if unit.contains("min") {
            self.timeRemaining = amount * 60
        } else {
            self.timeRemaining = amount
        }
        
        self.hasTimer = self.timeRemaining > 0
    }

    func start() {
        isTimerActive = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopAndNotify()
                }
            }
    }

    private func stopAndNotify() {
        isTimerActive = false
        timer?.cancel()
        playTone()
    }

    private func playTone() {
        // Standard system beep or custom sound
        guard let url = Bundle.main.url(forResource: "timer_end", withExtension: "mp3") else { return }
        try? audioPlayer = AVAudioPlayer(contentsOf: url)
        audioPlayer?.play()
        
        // Auto-stop after 1 second as requested
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.audioPlayer?.stop()
        }
    }
    
    func formatTime() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
