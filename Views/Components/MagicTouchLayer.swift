import SwiftUI

// MARK: - Magic Touch Layer
// A gentle interactive overlay for the story-detail hero artwork: tapping
// anywhere releases a calm little burst of fireflies/sparkles that twinkle,
// drift upward, and fade. Quiet by design — no sound, no haptics, nothing
// flashy — so it delights without working against bedtime.
//
// Used ONLY on the StoryDetailView hero. Never place this inside
// StoryArtworkView or on story cards: cards sit inside NavigationLinks and
// must keep their decorative layers hit-test disabled.

struct MagicTouchLayer: View {
    @State private var bursts: [SparkleBurst] = []

    var body: some View {
        ZStack {
            ForEach(bursts) { burst in
                SparkleBurstView(burst: burst)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { location in
            let burst = SparkleBurst(center: location)
            bursts.append(burst)
            // Retire the burst after its animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                bursts.removeAll { $0.id == burst.id }
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Burst model

private struct SparkleBurst: Identifiable {
    let id = UUID()
    let center: CGPoint
    let sparkles: [Sparkle]

    init(center: CGPoint) {
        self.center = center
        let step: Double = 2.0 * Double.pi / 5.0
        var made: [Sparkle] = []
        for i in 0..<5 {
            let jitter = Double.random(in: -0.4...0.4)
            let angle: Double = Double(i) * step + jitter
            let sparkle = Sparkle(
                angle: angle,
                distance: CGFloat.random(in: 18...42),
                size: CGFloat.random(in: 6...11),
                delay: Double(i) * 0.06,
                symbol: i == 0 ? "moon.stars.fill" : "sparkle"
            )
            made.append(sparkle)
        }
        self.sparkles = made
    }

    struct Sparkle: Identifiable {
        let id = UUID()
        let angle: Double
        let distance: CGFloat
        let size: CGFloat
        let delay: Double
        let symbol: String
    }
}

// MARK: - Burst view

private struct SparkleBurstView: View {
    let burst: SparkleBurst
    @State private var bloomed = false

    var body: some View {
        ZStack {
            // Soft glow ring at the touch point
            Circle()
                .stroke(Color.white.opacity(bloomed ? 0 : 0.35), lineWidth: 1.5)
                .frame(width: bloomed ? 64 : 8, height: bloomed ? 64 : 8)
                .position(burst.center)
                .blur(radius: 1)

            ForEach(burst.sparkles) { sparkle in
                Image(systemName: sparkle.symbol)
                    .font(.system(size: sparkle.size))
                    .foregroundStyle(.white.opacity(bloomed ? 0 : 0.9))
                    .shadow(color: .yellow.opacity(0.7), radius: 4)
                    .scaleEffect(bloomed ? 1.0 : 0.2)
                    .position(
                        x: burst.center.x + (bloomed ? cos(sparkle.angle) * sparkle.distance : 0),
                        y: burst.center.y + (bloomed ? sin(sparkle.angle) * sparkle.distance - 18 : 0)
                    )
                    .animation(
                        .easeOut(duration: 1.8).delay(sparkle.delay),
                        value: bloomed
                    )
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeOut(duration: 1.8)) {
                bloomed = true
            }
        }
    }
}
