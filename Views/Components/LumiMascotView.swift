import SwiftUI

/// A helper struct that maps Bible story IDs to fun Lumi reactions and messages
struct LumiReaction {
    static func reaction(for storyID: String) -> String {
        switch storyID.lowercased() {
        case "noah-big-boat":
            return "✨ Wow! That's quite a big boat!"
        case "david-and-goliath":
            return "✨ What a brave little hero!"
        case "creation-story":
            return "✨ The world is so beautiful!"
        case "daniel-and-the-lions":
            return "✨ Daniel was so brave!"
        case "the-good-samaritan":
            return "✨ That was so kind!"
        case "jesus-calms-the-storm":
            return "✨ Jesus has all the power!"
        case "the-lost-sheep":
            return "✨ Every little one matters!"
        case "the-birth-of-jesus":
            return "✨ The most special baby!"
        case "jonah-and-the-big-fish":
            return "✨ What a big fish! Splash!"
        case "baby-moses":
            return "✨ Safe in the basket!"
        case "joseph-and-his-colorful-coat":
            return "✨ So many beautiful colors!"
        case "esthers-courage":
            return "✨ What a brave queen!"
        case "the-prodigal-son":
            return "✨ Welcome home!"
        case "the-empty-tomb":
            return "✨ He is risen!"
        default:
            return "✨ What a wonderful story!"
        }
    }
}

/// A glowing firefly mascot character for the Bible bedtime app
/// Displays animated firefly emoji with optional speech bubble messages
struct LumiMascotView: View {
    @EnvironmentObject var settings: AppSettings

    let size: CGFloat
    let message: String?

    @State private var isGlowing = false
    @State private var showSpeechBubble = false

    init(size: CGFloat = 32, message: String? = nil) {
        self.size = size
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            firefly
                .onAppear {
                    startGlowAnimation()
                    if message != nil {
                        showSpeechBubble = true
                        dismissSpeechBubbleAfterDelay()
                    }
                }
                .onChange(of: message) { oldValue, newValue in
                    if newValue != nil {
                        showSpeechBubble = true
                        dismissSpeechBubbleAfterDelay()
                    }
                }

            if showSpeechBubble, let message = message {
                speechBubble(with: message)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
    }

    // MARK: - Subviews

    private var firefly: some View {
        Text("✨")
            .font(.system(size: size))
            .scaleEffect(isGlowing ? 1.1 : 0.95)
            .opacity(isGlowing ? 1 : 0.7)
            .shadow(color: AppTheme.accent(for: settings.isBedtimeMode).opacity(0.8), radius: isGlowing ? 12 : 4)
    }

    @ViewBuilder
    private func speechBubble(with text: String) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppTheme.cardBackground(for: settings.isBedtimeMode))
                .opacity(0.95)
        )
        .overlay(
            Capsule()
                .stroke(AppTheme.accent(for: settings.isBedtimeMode), lineWidth: 1.5)
        )
    }

    // MARK: - Animations

    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isGlowing = true
        }
    }

    private func dismissSpeechBubbleAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSpeechBubble = false
            }
        }
    }
}
