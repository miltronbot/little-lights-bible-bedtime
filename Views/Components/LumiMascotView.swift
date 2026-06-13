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
        // The bubble is an OVERLAY, not a stacked sibling: it must never
        // occupy layout, or every show/hide bobs the whole page up and down
        // (this was visibly rocking the Home scroll — owner bug report).
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
            .overlay(alignment: .topTrailing) {
                if showSpeechBubble, let message = message {
                    speechBubble(with: message)
                        .frame(width: 210, alignment: .trailing)
                        .offset(y: size + 18)
                        .transition(.scale(scale: 0.8).combined(with: .opacity))
                        .allowsHitTesting(false)
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
            // Scoped to the glow only — withAnimation(.repeatForever) in
            // onAppear leaks into surrounding layout (Home-page bobbing)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isGlowing)
    }

    @ViewBuilder
    private func speechBubble(with text: String) -> some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(3)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 210)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.cardBackground(for: settings.isBedtimeMode))
                .opacity(0.95)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.accent(for: settings.isBedtimeMode), lineWidth: 1.5)
        )
    }

    // MARK: - Animations

    private func startGlowAnimation() {
        isGlowing = true
    }

    private func dismissSpeechBubbleAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSpeechBubble = false
            }
        }
    }
}

// MARK: - Wandering Lumi
// Lumi flies around the screen naturally: she drifts between random
// waypoints on slow, eased glides with a gentle bob, like a real
// firefly. Tapping her shows her reaction to the current story.
// Only Lumi herself is tappable — the rest of the overlay passes
// touches through to the content beneath.

struct WanderingLumiView: View {
    let storyID: String

    @State private var position: CGPoint = .zero
    @State private var bobbing = false
    @State private var message: String? = nil
    @State private var started = false

    var body: some View {
        GeometryReader { geo in
            LumiMascotView(size: 38, message: message)
                .offset(y: bobbing ? -7 : 7)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: bobbing)
                .position(position == .zero ? startPoint(in: geo.size) : position)
                .onTapGesture {
                    // Glide toward the middle first so her speech bubble
                    // never runs off the screen edge
                    let safe = CGPoint(
                        x: min(max(position.x, geo.size.width * 0.32), geo.size.width * 0.68),
                        y: min(max(position.y, geo.size.height * 0.22), geo.size.height * 0.65)
                    )
                    withAnimation(.easeInOut(duration: 0.5)) {
                        position = safe
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        message = LumiReaction.reaction(for: storyID)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        message = nil
                    }
                }
                .task {
                    guard !started else { return }
                    started = true
                    position = startPoint(in: geo.size)
                    // Gentle continuous bob (animation scoped on the view)
                    bobbing = true
                    // Natural wandering: glide to a new spot, pause, repeat
                    while !Task.isCancelled {
                        let flight = Double.random(in: 6.0...10.0)
                        withAnimation(.easeInOut(duration: flight)) {
                            position = randomPoint(in: geo.size)
                        }
                        try? await Task.sleep(for: .seconds(flight + Double.random(in: 0.8...2.5)))
                    }
                }
        }
        .accessibilityLabel("Lumi the firefly — tap to say hi")
    }

    private func startPoint(in size: CGSize) -> CGPoint {
        CGPoint(x: size.width * 0.82, y: size.height * 0.20)
    }

    private func randomPoint(in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width * .random(in: 0.14...0.86),
            y: size.height * .random(in: 0.16...0.72)
        )
    }
}
