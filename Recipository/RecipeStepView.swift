//
//  RecipeStepView.swift
//  Recipository
//

import SwiftUI

struct RecipeStepView: View {
    let detail: MealDetail?
    @Binding var currentStepIndex: Int
    let isLoading: Bool
    var handCoach: CookingHandCoach

    @State private var boxHeight: CGFloat = 160
    private let minHeight: CGFloat = 80
    private let maxHeight: CGFloat = 400

    private var steps: [String] { detail?.steps ?? [] }
    private var hasPrev: Bool { currentStepIndex > 0 }
    private var hasNext: Bool { currentStepIndex < steps.count - 1 }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 6) {

                    // Prev button
                    Button {
                        if hasPrev { currentStepIndex -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .opacity(hasPrev ? 1 : 0.25)
                    .disabled(!hasPrev)

                    // Step content
                    VStack(alignment: .leading, spacing: 4) {
                        if steps.isEmpty {
                            Text("No steps available.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            HStack(spacing: 6) {
                                Text("Step \(currentStepIndex + 1) of \(steps.count)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                if handCoach.isHandTrackingActive {
                                    Circle()
                                        .fill(.green.opacity(0.85))
                                        .frame(width: 6, height: 6)
                                        .accessibilityLabel("Hand coaching active")
                                }
                            }

                            Text(steps[currentStepIndex])
                                .font(.callout)
                                .minimumScaleFactor(0.4)
                                .lineLimit(nil)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: boxHeight)
                    .padding(.horizontal, 2)

                    // Next button
                    Button {
                        if hasNext { currentStepIndex += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .opacity(hasNext ? 1 : 0.25)
                    .disabled(!hasNext)
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)

                // Drag handle at the bottom edge
                dragHandle
            }

            if let tip = handCoach.bannerMessage {
                Text(tip)
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.horizontal, 4)
                    .padding(.bottom, 2)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: handCoach.bannerMessage)
    }

    private var dragHandle: some View {
        ZStack {
            // Invisible wide hit area for easy grabbing
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 16)
                .contentShape(Rectangle())

            // Visual pill indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 32, height: 4)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newHeight = boxHeight + value.translation.height
                    boxHeight = min(max(newHeight, minHeight), maxHeight)
                }
        )

    }
}
