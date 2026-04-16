import SwiftUI

// MARK: - Panel Registry
// Stories whose original image was a 2x2 Midjourney grid — split into 4 individual panels

private let storyPanels: [String: [String]] = [
    "jesus-and-the-woman-at-the-well": ["jesus-and-the-woman-at-the-well-1", "jesus-and-the-woman-at-the-well-2", "jesus-and-the-woman-at-the-well-3", "jesus-and-the-woman-at-the-well-4"],
    "jesus-in-the-garden-of-gethsemane": ["jesus-in-the-garden-of-gethsemane-1", "jesus-in-the-garden-of-gethsemane-2", "jesus-in-the-garden-of-gethsemane-3", "jesus-in-the-garden-of-gethsemane-4"],
    "jesus-washes-the-disciples-feet": ["jesus-washes-the-disciples-feet-1", "jesus-washes-the-disciples-feet-2", "jesus-washes-the-disciples-feet-3", "jesus-washes-the-disciples-feet-4"],
    "mary-and-martha": ["mary-and-martha-1", "mary-and-martha-2", "mary-and-martha-3", "mary-and-martha-4"],
    "noah-big-boat": ["noah-big-boat-1", "noah-big-boat-2", "noah-big-boat-3", "noah-big-boat-4"],
    "peter-walks-on-water": ["peter-walks-on-water-1", "peter-walks-on-water-2", "peter-walks-on-water-3", "peter-walks-on-water-4"],
    "the-empty-tomb": ["the-empty-tomb-1", "the-empty-tomb-2", "the-empty-tomb-3", "the-empty-tomb-4"],
    "the-light-of-the-world": ["the-light-of-the-world-1", "the-light-of-the-world-2", "the-light-of-the-world-3", "the-light-of-the-world-4"],
    "the-talents": ["the-talents-1", "the-talents-2", "the-talents-3", "the-talents-4"],
    "the-ten-lepers": ["the-ten-lepers-1", "the-ten-lepers-2", "the-ten-lepers-3", "the-ten-lepers-4"],
    "the-widows-offering": ["the-widows-offering-1", "the-widows-offering-2", "the-widows-offering-3", "the-widows-offering-4"]
]
// MARK: - StoryArtworkView

struct StoryArtworkView: View {
    let story: Story
    let cornerRadius: CGFloat

    @EnvironmentObject private var appSettings: AppSettings
    @State private var currentPanel: Int = 0

    private var style: StoryArtworkStyle {
        StoryArtwork.style(for: story.id, bedtimeMode: appSettings.isBedtimeMode)
    }

    private var panels: [String]? {
        storyPanels[story.id]
    }

    var body: some View {
        GeometryReader { geo in
            if let panels = panels {
                // ── Swipeable carousel for split-panel stories ──
                ZStack(alignment: .bottom) {
                    TabView(selection: $currentPanel) {
                        ForEach(Array(panels.enumerated()), id: \.offset) { index, panelName in
                            Image(panelName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(width: geo.size.width, height: geo.size.height)

                    // Subtle dark gradient overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.45)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)

                    // Dot indicators
                    HStack(spacing: 6) {
                        ForEach(0..<panels.count, id: \.self) { i in
                            Circle()
                                .fill(i == currentPanel ? Color.white : Color.white.opacity(0.4))
                                .frame(width: i == currentPanel ? 8 : 6,
                                       height: i == currentPanel ? 8 : 6)
                                .animation(.spring(response: 0.3), value: currentPanel)
                        }
                    }
                    .padding(.bottom, 12)
                    .allowsHitTesting(false)

                    // Atmospheric effects on top
                    AtmosphericGlow(style: style, category: story.category, size: geo.size)
                        .blendMode(.screen)
                        .opacity(0.2)
                        .allowsHitTesting(false)

                    AmbientParticlesLayer(category: story.category, size: geo.size)
                        .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))

                        } else if UIImage(named: story.id) != nil {
                // ── Single Midjourney illustration (aspect-ratio safe) ──
                ZStack {
                    Image(story.id)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .blur(radius: 12)
                        .scaleEffect(1.05)

                    Image(story.id)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.45)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)

                    AtmosphericGlow(style: style, category: story.category, size: geo.size)
                        .blendMode(.screen)
                        .opacity(0.2)
                        .allowsHitTesting(false)

                    AmbientParticlesLayer(category: story.category, size: geo.size)
                        .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))

            } else {
                // ── Procedural painted scene fallback ──
                ZStack {
                    PaintedSceneBackground(style: style, category: story.category, size: geo.size)
                        .allowsHitTesting(false)

                    SpotlightLayer(style: style, size: geo.size)
                        .allowsHitTesting(false)

                    GroundSilhouetteLayer(style: style, size: geo.size)
                        .allowsHitTesting(false)

                    SceneComposition(style: style, category: story.category, size: geo.size)
                        .allowsHitTesting(false)

                    AmbientParticlesLayer(category: story.category, size: geo.size)
                        .allowsHitTesting(false)

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.35)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .allowsHitTesting(false)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
    }
}

// MARK: - Painted Scene Background

private struct PaintedSceneBackground: View {
    let style: StoryArtworkStyle
    let category: StoryCategory
    let size: CGSize

    @State private var shimmer: Bool = false

    var body: some View {
        ZStack {
            // Base sky gradient — rich, multi-stop
            LinearGradient(
                stops: [
                    .init(color: skyTop, location: 0.0),
                    .init(color: skyMid, location: 0.45),
                    .init(color: skyHorizon, location: 0.75),
                    .init(color: groundColor, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Celestial body (sun or moon) — large, soft, glowing
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            celestialColor.opacity(0.9),
                            celestialColor.opacity(0.4),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: celestialRadius
                    )
                )
                .frame(width: celestialRadius * 2, height: celestialRadius * 2)
                .position(x: size.width * 0.78, y: size.height * 0.22)
                .blur(radius: 8)

            // Second soft glow for warmth
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            style.secondary.opacity(shimmer ? 0.45 : 0.28),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.55
                    )
                )
                .frame(width: size.width * 1.1, height: size.height * 0.55)
                .offset(x: -size.width * 0.1, y: size.height * 0.12)
                .blur(radius: 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }

    private var skyTop: Color { style.primary }
    private var skyMid: Color { style.secondary.opacity(0.5) }
    private var skyHorizon: Color { style.secondary.opacity(0.8) }
    private var groundColor: Color { style.primary.opacity(0.9) }

    private var celestialColor: Color {
        switch category {
        case .hope, .courage: return Color(red: 1.0, green: 0.90, blue: 0.55)
        case .peace, .trust:  return Color(red: 0.75, green: 0.88, blue: 1.0)
        case .love:           return Color(red: 1.0, green: 0.80, blue: 0.85)
        case .prayer:         return Color(red: 0.85, green: 0.80, blue: 1.0)
        case .kindness:       return Color(red: 0.80, green: 1.0, blue: 0.82)
        }
    }

    private var celestialRadius: CGFloat {
        min(size.width, size.height) * 0.22
    }
}

// MARK: - Spotlight Layer

private struct SpotlightLayer: View {
    let style: StoryArtworkStyle
    let size: CGSize

    @State private var pulse: Bool = false

    var body: some View {
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(pulse ? 0.18 : 0.10),
                        Color.white.opacity(0.04),
                        .clear
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size.width * 0.45
                )
            )
            .frame(width: size.width * 0.9, height: size.height * 0.65)
            .position(x: size.width * 0.5, y: size.height * 0.38)
            .blur(radius: 18)
            .onAppear {
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
    }
}

// MARK: - Ground Silhouette Layer

private struct GroundSilhouetteLayer: View {
    let style: StoryArtworkStyle
    let size: CGSize

    var body: some View {
        ZStack(alignment: .bottom) {
            // Rolling hill silhouette
            Ellipse()
                .fill(style.primary.opacity(0.6))
                .frame(width: size.width * 1.6, height: size.height * 0.38)
                .offset(x: -size.width * 0.15, y: size.height * 0.18)
                .blur(radius: 2)

            // Second hill, slightly lighter
            Ellipse()
                .fill(style.primary.opacity(0.4))
                .frame(width: size.width * 1.3, height: size.height * 0.28)
                .offset(x: size.width * 0.2, y: size.height * 0.22)
                .blur(radius: 2)
        }
        .frame(width: size.width, height: size.height)
    }
}

// MARK: - Atmospheric Glow (used on real photos)

private struct AtmosphericGlow: View {
    let style: StoryArtworkStyle
    let category: StoryCategory
    let size: CGSize

    @State private var glowPulse: Bool = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [glowColor.opacity(glowPulse ? 0.35 : 0.2), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.5
                    )
                )
                .frame(width: size.width * 0.8, height: size.height * 0.6)
                .offset(x: size.width * 0.15, y: -size.height * 0.15)
                .blur(radius: 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }

    private var glowColor: Color {
        switch category {
        case .peace:    return .cyan
        case .love:     return .pink
        case .hope:     return .yellow
        case .courage:  return .orange
        case .trust:    return .blue
        case .prayer:   return .purple
        case .kindness: return .green
        }
    }
}

// MARK: - Ambient Particles Layer

private struct AmbientParticlesLayer: View {
    let category: StoryCategory
    let size: CGSize

    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                SparkleParticle(index: i, symbol: particleSymbol, size: size)
            }
        }
    }

    private var particleSymbol: String {
        switch category {
        case .peace:    return "sparkle"
        case .love:     return "heart.fill"
        case .hope:     return "sparkle"
        case .courage:  return "sparkle"
        case .trust:    return "sparkle"
        case .prayer:   return "sparkle"
        case .kindness: return "leaf.fill"
        }
    }
}

private struct SparkleParticle: View {
    let index: Int
    let symbol: String
    let size: CGSize

    @State private var isAnimating = false

    private var xPos: CGFloat {
        let positions: [CGFloat] = [0.08, 0.92, 0.25, 0.75, 0.15, 0.62, 0.88, 0.40, 0.55, 0.32, 0.78, 0.48]
        return size.width * positions[index % positions.count]
    }

    private var yPos: CGFloat {
        let positions: [CGFloat] = [0.10, 0.22, 0.68, 0.38, 0.82, 0.15, 0.50, 0.72, 0.28, 0.90, 0.44, 0.60]
        return size.height * positions[index % positions.count]
    }

    private var particleSize: CGFloat {
        let sizes: [CGFloat] = [5, 9, 4, 11, 6, 8, 4, 13, 7, 5, 10, 6]
        return sizes[index % sizes.count]
    }

    private var animDuration: Double {
        let durations: [Double] = [2.5, 3.2, 2.8, 3.8, 2.2, 3.0, 2.7, 3.5, 2.4, 3.3, 2.6, 3.1]
        return durations[index % durations.count]
    }

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: particleSize))
            .foregroundStyle(.white.opacity(isAnimating ? 0.7 : 0.08))
            .scaleEffect(isAnimating ? 1.3 : 0.5)
            .offset(y: isAnimating ? -10 : 10)
            .position(x: xPos, y: yPos)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: animDuration)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.35)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Scene Composition

private struct SceneComposition: View {
    let style: StoryArtworkStyle
    let category: StoryCategory
    let size: CGSize

    var body: some View {
        ZStack {
            // Large soft glow behind main symbol
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.22), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: mainSymbolSize * 2.5
                    )
                )
                .frame(width: mainSymbolSize * 5, height: mainSymbolSize * 5)
                .position(x: size.width * 0.5, y: size.height * 0.42)
                .blur(radius: 12)

            // Outer decorative ring
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 2)
                .frame(width: mainSymbolSize * 4.0, height: mainSymbolSize * 4.0)
                .position(x: size.width * 0.5, y: size.height * 0.42)

            // Inner halo
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: mainSymbolSize * 2.8, height: mainSymbolSize * 2.8)
                .position(x: size.width * 0.5, y: size.height * 0.42)

            // Main symbol — large, glowing, prominent
            SceneElement(
                symbol: style.symbolName,
                size: mainSymbolSize,
                x: 0.5,
                y: 0.42,
                color: .white,
                opacity: 1.0,
                animation: .float,
                containerSize: size,
                shadowRadius: 16
            )

            // Accent symbol
            if let accent = style.accentSymbolName {
                SceneElement(
                    symbol: accent,
                    size: accentSymbolSize,
                    x: 0.76,
                    y: 0.22,
                    color: .white,
                    opacity: 0.85,
                    animation: .drift,
                    containerSize: size,
                    shadowRadius: 8
                )
            }

            categoryDecorations
        }
    }

    private var mainSymbolSize: CGFloat { min(size.width, size.height) * 0.30 }
    private var accentSymbolSize: CGFloat { min(size.width, size.height) * 0.14 }

    @ViewBuilder
    private var categoryDecorations: some View {
        switch category {
        case .peace:
            SceneElement(symbol: "water.waves", size: accentSymbolSize * 0.9, x: 0.18, y: 0.80,
                         color: .white, opacity: 0.45, animation: .drift, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "water.waves", size: accentSymbolSize * 0.7, x: 0.72, y: 0.84,
                         color: .white, opacity: 0.30, animation: .drift, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "cloud.fill", size: accentSymbolSize, x: 0.14, y: 0.14,
                         color: .white, opacity: 0.35, animation: .drift, containerSize: size, shadowRadius: 4)
        case .love:
            SceneElement(symbol: "heart.fill", size: accentSymbolSize * 0.55, x: 0.15, y: 0.28,
                         color: .pink, opacity: 0.65, animation: .pulse, containerSize: size, shadowRadius: 6)
            SceneElement(symbol: "heart.fill", size: accentSymbolSize * 0.40, x: 0.84, y: 0.62,
                         color: .pink, opacity: 0.50, animation: .pulse, containerSize: size, shadowRadius: 6)
            SceneElement(symbol: "sparkle", size: accentSymbolSize * 0.45, x: 0.28, y: 0.72,
                         color: .white, opacity: 0.50, animation: .twinkle, containerSize: size, shadowRadius: 4)
        case .hope:
            SceneElement(symbol: "star.fill", size: accentSymbolSize * 0.50, x: 0.12, y: 0.14,
                         color: .yellow, opacity: 0.80, animation: .twinkle, containerSize: size, shadowRadius: 8)
            SceneElement(symbol: "star.fill", size: accentSymbolSize * 0.38, x: 0.88, y: 0.12,
                         color: .yellow, opacity: 0.65, animation: .twinkle, containerSize: size, shadowRadius: 6)
            SceneElement(symbol: "star.fill", size: accentSymbolSize * 0.30, x: 0.42, y: 0.10,
                         color: .yellow, opacity: 0.55, animation: .twinkle, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "sparkle", size: accentSymbolSize * 0.6, x: 0.86, y: 0.76,
                         color: .yellow, opacity: 0.40, animation: .pulse, containerSize: size, shadowRadius: 4)
        case .courage:
            SceneElement(symbol: "bolt.fill", size: accentSymbolSize * 0.55, x: 0.18, y: 0.18,
                         color: .yellow, opacity: 0.70, animation: .twinkle, containerSize: size, shadowRadius: 6)
            SceneElement(symbol: "shield.fill", size: accentSymbolSize * 0.50, x: 0.84, y: 0.72,
                         color: .white, opacity: 0.40, animation: .float, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "sparkle", size: accentSymbolSize * 0.40, x: 0.14, y: 0.70,
                         color: .orange, opacity: 0.55, animation: .twinkle, containerSize: size, shadowRadius: 4)
        case .trust:
            SceneElement(symbol: "hands.sparkles.fill", size: accentSymbolSize * 0.55, x: 0.18, y: 0.74,
                         color: .white, opacity: 0.45, animation: .pulse, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "sparkle", size: accentSymbolSize * 0.45, x: 0.86, y: 0.68,
                         color: .cyan, opacity: 0.60, animation: .twinkle, containerSize: size, shadowRadius: 6)
            SceneElement(symbol: "star.fill", size: accentSymbolSize * 0.35, x: 0.10, y: 0.12,
                         color: .white, opacity: 0.55, animation: .twinkle, containerSize: size, shadowRadius: 4)
        case .prayer:
            SceneElement(symbol: "moon.stars.fill", size: accentSymbolSize * 0.60, x: 0.14, y: 0.16,
                         color: .yellow, opacity: 0.70, animation: .pulse, containerSize: size, shadowRadius: 8)
            SceneElement(symbol: "sparkle", size: accentSymbolSize * 0.38, x: 0.88, y: 0.28,
                         color: .white, opacity: 0.60, animation: .twinkle, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "sparkle", size: accentSymbolSize * 0.30, x: 0.28, y: 0.78,
                         color: Color(red: 0.8, green: 0.7, blue: 1.0), opacity: 0.55, animation: .twinkle, containerSize: size, shadowRadius: 4)
        case .kindness:
            SceneElement(symbol: "leaf.fill", size: accentSymbolSize * 0.55, x: 0.14, y: 0.68,
                         color: .green, opacity: 0.60, animation: .float, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "leaf.fill", size: accentSymbolSize * 0.40, x: 0.86, y: 0.58,
                         color: .green, opacity: 0.45, animation: .float, containerSize: size, shadowRadius: 4)
            SceneElement(symbol: "heart.fill", size: accentSymbolSize * 0.38, x: 0.20, y: 0.22,
                         color: .pink, opacity: 0.55, animation: .pulse, containerSize: size, shadowRadius: 6)
        }
    }
}

// MARK: - Scene Element

private enum SceneAnimation {
    case float, drift, twinkle, pulse, none
}

private struct SceneElement: View {
    let symbol: String
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    let color: Color
    let opacity: Double
    let animation: SceneAnimation
    let containerSize: CGSize
    var shadowRadius: CGFloat = 0

    @State private var isAnimating = false

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(color.opacity(opacity))
            .shadow(color: color.opacity(0.6), radius: shadowRadius, x: 0, y: 0)
            .modifier(AnimationModifier(animation: animation, isAnimating: isAnimating))
            .position(x: containerSize.width * x, y: containerSize.height * y)
            .onAppear {
                guard animation != .none else { return }
                withAnimation(
                    .easeInOut(duration: animDuration)
                    .repeatForever(autoreverses: true)
                    .delay(animDelay)
                ) {
                    isAnimating = true
                }
            }
    }

    private var animDuration: Double {
        switch animation {
        case .float:   return 2.8
        case .drift:   return 4.5
        case .twinkle: return 1.8
        case .pulse:   return 2.4
        case .none:    return 0
        }
    }

    private var animDelay: Double { (x + y) * 0.9 }
}

private struct AnimationModifier: ViewModifier {
    let animation: SceneAnimation
    let isAnimating: Bool

    func body(content: Content) -> some View {
        switch animation {
        case .float:
            content.offset(y: isAnimating ? -8 : 8)
        case .drift:
            content.offset(x: isAnimating ? 10 : -10, y: isAnimating ? -4 : 4)
        case .twinkle:
            content.opacity(isAnimating ? 1.0 : 0.2).scaleEffect(isAnimating ? 1.1 : 0.9)
        case .pulse:
            content.scaleEffect(isAnimating ? 1.20 : 0.82)
        case .none:
            content
        }
    }
}
