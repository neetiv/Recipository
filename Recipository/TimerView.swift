//
//  TimerView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var manager = TimerManager()
    let stepString: String

    var body: some View {
        Group {
            if manager.hasTimer {
                VStack(spacing: 4) {
                    Text(manager.formatTime())
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.bold)
                    
                    Button(action: { manager.start() }) {
                        Image(systemName: manager.isTimerActive ? "timer" : "play.fill")
                            .font(.caption)
                    }
                    .controlSize(.small)
                    .disabled(manager.isTimerActive)
                }
                .padding(8)
            } else {
                // Return a clear frame if no timer is needed
                // This keeps the HStack layout consistent
                Spacer()
                    .frame(width: 0)
            }
        }
        .onAppear {
            manager.determineTime(from: stepString)
        }
        // CRITICAL: This updates the timer when the user changes steps
        .onChange(of: stepString) { oldValue, newValue in
            manager.determineTime(from: newValue)
        }
    }
}
