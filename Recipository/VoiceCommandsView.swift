//
//  VoiceCommandsView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct VoiceCommandsView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Label("Voice Commands", systemImage: "mic.fill")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Use these commands while cooking to navigate hands-free.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Command list
            VStack(alignment: .leading, spacing: 12) {
                voiceCommandRow(icon: "play.fill", command: "\"Start recipe\"", description: "Begin cooking mode")
                voiceCommandRow(icon: "forward.fill", command: "\"Next step\"", description: "Go to the next step")
                voiceCommandRow(icon: "backward.fill", command: "\"Go back\"", description: "Return to previous step")
                voiceCommandRow(icon: "timer", command: "\"Set timer\"", description: "Start a countdown timer")
                voiceCommandRow(icon: "list.bullet", command: "\"Read ingredients\"", description: "List all ingredients")
                voiceCommandRow(icon: "arrow.counterclockwise", command: "\"Repeat\"", description: "Hear the current step again")
            }

            Divider()

            // Dismiss button
            Button {
                withAnimation(.easeOut(duration: 0.25)) {
                    onDismiss()
                }
            } label: {
                Text("Got it!")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(width: 420)
        .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.3))
        .glassBackgroundEffect()
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private func voiceCommandRow(icon: String, command: String, description: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.tint)
                .frame(width: 24, alignment: .center)

            Text(command)
                .fontWeight(.medium)

            Spacer()

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
