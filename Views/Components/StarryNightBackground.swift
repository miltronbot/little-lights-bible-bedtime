
import SwiftUI

// MARK: - Animated Starry Night Background
// Creates a magical twinkling night sky effect for bedtime mode

struct StarryNightBackground: View {
    /// When true, stars show even outside bedtime mode — a calmer version
    /// (dimmer stars, no floating particles) so it reads as ambience, not
    /// decoration. Used by the Home screen.
    var alwaysStarry: Bool = false

    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.colorScheme) private var colorScheme
    @State private var stars: [Star] = []
    @State private var shootingStarOffset: CGFloat = -100

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
        let twinkleSpeed: Double
        let delay: Double
    }

    private var showStars: Bool { appSettings.isBedtimeMode || alwaysStarry }

    // Subtle mode tones the stars down so the sky stays in the background
    private var subtle: Bool { alwaysStarry && !appSettings.isBedtimeMode }

    private var skyColors: [Color] {
        if appSettings.isBedtimeMode {
            return [Color(red: 0.02, green: 0.06, blue: 0.09),
                    Color(red: 0.04, green: 0.10, blue: 0.13),
                    Color(red: 0.07, green: 0.14, blue: 0.16)]
        }
        if alwaysStarry {
            if colorScheme == .dark {
                // Wise Men night: deep teal-navy with a soft teal horizon
                return [Color(red: 0.03, green: 0.09, blue: 0.12),
                        Color(red: 0.05, green: 0.13, blue: 0.16),
                        Color(red: 0.10, green: 0.19, blue: 0.20)]
            } else {
                // Pale twilight for light mode — keeps dark text readable
                return [Color(red: 0.91, green: 0.91, blue: 0.97),
                        Color(red: 0.94, green: 0.93, blue: 0.98),
                        Color(red: 0.96, green: 0.95, blue: 0.99)]
            }
        }
        return [Color(.systemGroupedBackground), Color(.systemGroupedBackground)]
    }

    private var starColor: Color {
        subtle && colorScheme == .light ? Color.indigo : Color.white
    }

    private var starIntensity: Double {
        subtle ? 0.7 : 1.0
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Night (or twilight) gradient
                LinearGradient(
                    colors: skyColors,
                    startPoint: .top,
                    endPoint: .bottom
                )

                if showStars {
                    // Subtle aurora glow
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [Color(red: 1.0, green: 0.85, blue: 0.55).opacity(subtle ? 0.07 : 0.12), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.6
                            )
                        )
                        .frame(width: geo.size.width * 1.2, height: geo.size.height * 0.5)
                        .offset(y: -geo.size.height * 0.15)
                        .blur(radius: 30)

                    // Twinkling stars
                    ForEach(stars) { star in
                        TwinklingStar(star: star, color: starColor, intensity: starIntensity)
                    }

                    // Gentle floating particles — bedtime only; the subtle
                    // mode stays still so it never competes with content
                    if !subtle {
                        FloatingParticles()
                    }
                }
            }
            .onAppear {
                generateStars(in: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    private func generateStars(in size: CGSize) {
        guard stars.isEmpty else { return }
        var generated: [Star] = []
        _ = SeededRandom(seed: 42) // Available for deterministic placement if needed

        for _ in 0..<60 {
            let star = Star(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height * 0.7),
                size: CGFloat.random(in: 1.5...4.0),
                opacity: Double.random(in: 0.3...1.0),
                twinkleSpeed: Double.random(in: 1.5...4.0),
                delay: Double.random(in: 0...3.0)
            )
            generated.append(star)
        }
        stars = generated
    }
}

// MARK: - Twinkling Star

struct TwinklingStar: View {
    let star: StarryNightBackground.Star
    var color: Color = .white
    var intensity: Double = 1.0
    @State private var isTwinkling = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: star.size, height: star.size)
            .opacity((isTwinkling ? star.opacity : star.opacity * 0.3) * intensity)
            .shadow(color: color.opacity(0.5 * intensity), radius: star.size)
            .position(x: star.x, y: star.y)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: star.twinkleSpeed)
                    .repeatForever(autoreverses: true)
                    .delay(star.delay)
                ) {
                    isTwinkling = true
                }
            }
    }
}

// MARK: - Floating Particles (firefly-like gentle glow)

struct FloatingParticles: View {
    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        let size: CGFloat
        let floatDuration: Double
        let opacity: Double
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.yellow.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .blur(radius: 1)
                    .modifier(FloatAnimation(
                        startX: particle.x,
                        startY: particle.y,
                        duration: particle.floatDuration
                    ))
            }
            .onAppear {
                guard particles.isEmpty else { return }
                for _ in 0..<12 {
                    particles.append(Particle(
                        x: CGFloat.random(in: 20...(geo.size.width - 20)),
                        y: CGFloat.random(in: 20...(geo.size.height - 20)),
                        size: CGFloat.random(in: 2...5),
                        floatDuration: Double.random(in: 4...8),
                        opacity: Double.random(in: 0.15...0.4)
                    ))
                }
            }
        }
    }
}

struct FloatAnimation: ViewModifier {
    let startX: CGFloat
    let startY: CGFloat
    let duration: Double

    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0

    func body(content: Content) -> some View {
        content
            .offset(offset)
            .opacity(opacity)
            .position(x: startX, y: startY)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offset = CGSize(
                        width: CGFloat.random(in: -30...30),
                        height: CGFloat.random(in: -40...40)
                    )
                    opacity = 1
                }
            }
    }
}

// Simple seeded random for deterministic star placement
struct SeededRandom {
    var seed: UInt64
    mutating func next() -> Double {
        seed = seed &* 6364136223846793005 &+ 1442695040888963407
        return Double(seed >> 33) / Double(UInt32.max)
    }
}
