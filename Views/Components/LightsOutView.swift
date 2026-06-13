import SwiftUI

// MARK: - Lights Out
// A near-black full-screen cover shown while narration plays: the screen
// goes dark (effectively off on OLED) while audio and Tonight's Queue
// continue. A tiny moon drifts slowly so a waking parent can tell the
// app is alive. Double-tap anywhere to wake.

struct LightsOutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings

    @State private var moonOffset: CGSize = CGSize(width: -60, height: -40)
    @State private var showHint = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Tiny drifting moon — the only light in the room
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 26))
                .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.62).opacity(0.35))
                .offset(moonOffset)
                .animation(.easeInOut(duration: 60).repeatForever(autoreverses: true), value: moonOffset)
                .onAppear { moonOffset = CGSize(width: 60, height: 30) }

            if showHint {
                VStack(spacing: 10) {
                    if audioPlayer.isPlaying, let story = audioPlayer.currentStory {
                        Text("Playing \u{201C}\(story.title)\u{201D}")
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    Text(appSettings.kidLock ? "Hold 3 seconds to wake" : "Double-tap to wake")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.45))
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 60)
                .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            // With Kid Lock on, little taps can't wake the screen
            if !appSettings.kidLock { dismiss() }
        }
        .onLongPressGesture(minimumDuration: 3) {
            if appSettings.kidLock { dismiss() }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .onAppear {
            // Let the hint glow briefly, then true darkness
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.easeOut(duration: 2)) {
                    showHint = false
                }
            }
        }
    }
}
