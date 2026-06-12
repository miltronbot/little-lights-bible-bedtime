import SwiftUI

// MARK: - ConfettiView
/// A fullscreen overlay with animated falling confetti pieces
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                Text(piece.emoji)
                    .font(.system(size: 24))
                    .foregroundStyle(piece.color)
                    .rotationEffect(.degrees(piece.rotation))
                    .offset(x: piece.xPosition, y: piece.yPosition)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            generateConfetti()
            animateConfetti()
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [.yellow, .indigo, .pink, .cyan, .orange]
        let emojis = ["🎉", "✨", "🎊", "⭐", "💫"]

        confettiPieces = (0..<20).map { _ in
            ConfettiPiece(
                id: UUID(),
                emoji: emojis.randomElement() ?? "🎉",
                color: colors.randomElement() ?? .yellow,
                xPosition: CGFloat.random(in: -100...100),
                yPosition: -50,
                rotation: CGFloat.random(in: 0...360),
                delay: Double.random(in: 0...0.3)
            )
        }
    }

    private func animateConfetti() {
        for (index, piece) in confettiPieces.enumerated() {
            let delay = piece.delay  // capture value, not index, to avoid stale access
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard index < confettiPieces.count else { return }
                withAnimation(.linear(duration: 1.5)) {
                    confettiPieces[index].yPosition = 900
                    confettiPieces[index].rotation += 360
                }
            }
        }
    }
}

// MARK: - ConfettiPiece Model
struct ConfettiPiece {
    let id: UUID
    let emoji: String
    let color: Color
    var xPosition: CGFloat
    var yPosition: CGFloat
    var rotation: CGFloat
    let delay: Double
}

// MARK: - StoryCelebrationView
/// A fullscreen overlay shown when completing a story with celebration effects
struct StoryCelebrationView: View {
    @EnvironmentObject var appSettings: AppSettings

    let collectible: Collectible?
    var shootingStar: Bool = false
    let onDone: () -> Void

    @State private var showContent = false
    @State private var checkmarkScale: CGFloat = 0.1
    @State private var checkmarkOpacity: Double = 0

    var body: some View {
        ZStack {
            // Dark blurred background
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()

            // Confetti
            ConfettiView()

            // Celebration content
            if showContent {
                VStack(spacing: 24) {
                    // Checkmark with bounce animation
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 76))
                        .foregroundStyle(
                            LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                        )
                        .shadow(color: .green.opacity(0.6), radius: 14)
                        .scaleEffect(checkmarkScale)
                        .opacity(checkmarkOpacity)

                    // Story Complete text
                    Text(appSettings.activeChildName.isEmpty ? "Story Complete!" : "Great job, \(appSettings.activeChildName)!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    // Sleep Star reward
                    Text("+1 Sleep Star ⭐")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(.yellow)

                    if shootingStar {
                        Text("A shooting star! +1 bonus ⭐🌠")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.cyan)
                    }

                    // Collectible reveal (if applicable)
                    if let collectible = collectible {
                        VStack(spacing: 12) {
                            CollectibleIconView(collectible: collectible, size: 76)

                            Text("New Collectible!")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.cyan)

                            Text(collectible.name)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        .padding(16)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    }
                }
                .scaleEffect(showContent ? 1.0 : 0.3)
                .opacity(showContent ? 1.0 : 0)
            }
        }
        .onAppear {
            animateContent()

            // Auto-dismiss after 3.2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showContent = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDone()
                }
            }
        }
    }

    private func animateContent() {
        // Pop-in scale animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
            showContent = true
        }

        // Checkmark bounce animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0)) {
                checkmarkScale = 1.2
                checkmarkOpacity = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                checkmarkScale = 1.0
            }
        }
    }
}

// MARK: - BadgeCelebrationView
/// A fullscreen overlay shown when earning a new badge
struct BadgeCelebrationView: View {
    let badgeID: String
    let badgeName: String
    let badgeDescription: String
    let onDone: () -> Void

    @State private var showContent = false
    @State private var badgeScale: CGFloat = 0.1
    @State private var badgeOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            // Dark blurred background
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { onDone() }

            // Confetti
            ConfettiView()

            // Badge content
            if showContent {
                VStack(spacing: 24) {
                    // Glow ring behind badge
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.yellow.opacity(glowOpacity), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)

                        // Badge medal — same artwork language as collectibles
                        BadgeIconView(badgeID: badgeID, size: 104)
                            .scaleEffect(badgeScale)
                            .opacity(badgeOpacity)
                    }

                    // Badge Earned text
                    Text("Badge Earned!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    // Badge name
                    Text(badgeName)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(.yellow)

                    // Badge description
                    Text(badgeDescription)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .scaleEffect(showContent ? 1.0 : 0.3)
                .opacity(showContent ? 1.0 : 0)
            }
        }
        .onAppear {
            animateContent()

            // Auto-dismiss after 3.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showContent = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDone()
                }
            }
        }
    }

    private func animateContent() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
            showContent = true
        }

        // Badge bounce animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                badgeScale = 1.2
                badgeOpacity = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
                badgeScale = 1.0
            }
        }

        // Glow pulse
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 0.6
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.purple.opacity(0.3)
            .ignoresSafeArea()

        StoryCelebrationView(
            collectible: Collectible.all.first,
            onDone: { }
        )
        .environmentObject(AppSettings())
    }
}
