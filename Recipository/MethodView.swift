import SwiftUI
import AVKit

// MARK: - MethodView

struct MethodView: View {
    let currentStep: String
    @State private var showPopover = false

    // Keys must match your bundled filenames exactly (e.g. "whisk.mp4")
    private let videoKeywords: [String] = [
        "whisk", "fold", "knead", "sift", "pipe",
        "temper", "blanch", "deglaze", "caramelize",
        "flambe", "julienne", "chiffonade", "score"
    ]

    private var matchedKeyword: String? {
        let lower = currentStep.lowercased()
        return videoKeywords.first { lower.contains($0) }
    }

    var body: some View {
        if let keyword = matchedKeyword {
            Button {
                showPopover = true
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "play.rectangle.fill")
                        .font(.title2)
                    Text("How to \(keyword.capitalized)")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
                .frame(width: 140, height: 70)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                VideoPopoverView(keyword: keyword)
            }
            .onChange(of: currentStep) { _, _ in
                showPopover = false
            }
        }
        // Nothing rendered if no keyword matched
    }
}

// MARK: - Popover

private struct VideoPopoverView: View {
    let keyword: String

    @State private var player: AVPlayer?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: "play.rectangle.fill")
                    .foregroundStyle(.purple)
                Text("How to \(keyword.capitalized)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Divider()

            // Video area
            ZStack {
                Color.black

                if let player {
                    VideoPlayer(player: player)
                        .onAppear { player.play() }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("Video not found in bundle.\nMake sure \(keyword).mp4 is added to the target.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .frame(width: 360, height: 240)
        }
        .frame(width: 360)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .onAppear { setupPlayer() }
        .onDisappear { player?.pause() }
    }

    private func setupPlayer() {
        guard let url = Bundle.main.url(forResource: keyword, withExtension: "mp4") else {
            return  // error state shown in body
        }
        let item = AVPlayerItem(url: url)
        // Loop the video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
        player = AVPlayer(playerItem: item)
    }
}
