import SwiftUI

// MARK: - Lumi's Night Sky
// A personal scene the child decorates. Two kinds of pieces can be placed:
//   1. A FIXED sticker palette (stars, moon, Lumi, clouds, hearts…) that is
//      ALWAYS available so the canvas is fun to play with from day one —
//      even before a single story has been finished.
//   2. EARNED collectibles, which behave exactly as before: tap to place,
//      drag to move, long-press to put back in the drawer.
// Both kinds persist per child. Collectibles keep their original store
// (`nightSky.positions`); stickers live in a PARALLEL store
// (`nightSky.stickers`) so old saved layouts keep loading untouched.

struct NightSkyView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var manager: CollectiblesManager

    /// Earned-collectible id → position as fractions of the canvas.
    @State private var placed: [String: CGPoint] = [:]
    /// Fixed-palette stickers placed on the canvas (each its own instance).
    @State private var stickers: [PlacedSticker] = []
    /// The backdrop scene the child picked (per child, defaults to starry).
    @State private var scene: NightSkyScene = .starryNight
    @State private var loaded = false

    private var positionsKey: String {
        ProfileScope.key("nightSky.positions", profile: appSettings.activeChildName)
    }

    private var stickersKey: String {
        ProfileScope.key("nightSky.stickers", profile: appSettings.activeChildName)
    }

    private var sceneKey: String {
        ProfileScope.key("nightSky.scene", profile: appSettings.activeChildName)
    }

    private var collected: [Collectible] {
        Collectible.all.filter { manager.hasCollected($0.id) }
    }

    private var drawerItems: [Collectible] {
        collected.filter { placed[$0.id] == nil }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // The child's chosen backdrop — starry sky by default, six
                // more scenes to pick from in the drawer
                Group {
                    if scene == .starryNight {
                        StarryNightBackground(alwaysStarry: true)
                    } else {
                        NightSkySceneBackdrop(scene: scene)
                    }
                }
                .allowsHitTesting(false)

                // Lumi keeps the child company while they decorate
                WanderingLumiView(storyID: "night-sky")
                    .allowsHitTesting(false)

                // The fixed palette means the canvas is never truly empty, so
                // the empty-state prompt only shows when nothing is placed yet.
                if placed.isEmpty && stickers.isEmpty {
                    VStack(spacing: 12) {
                        Text("🌌")
                            .font(.system(size: 56))
                        Text("Tap a sticker below to start your night sky!\nFinish stories to earn special treasures, too.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .allowsHitTesting(false)
                }

                // Placed palette stickers — drag to move, double-tap or
                // long-press to remove.
                ForEach(stickers) { sticker in
                    StickerView(emoji: sticker.emoji)
                        .position(x: sticker.x * geo.size.width, y: sticker.y * geo.size.height)
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.35)) {
                                stickers.removeAll { $0.id == sticker.id }
                            }
                            saveStickers()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    updateSticker(
                                        sticker.id,
                                        x: min(max(value.location.x / geo.size.width, 0.05), 0.95),
                                        y: min(max(value.location.y / geo.size.height, 0.08), 0.85)
                                    )
                                }
                                .onEnded { _ in saveStickers() }
                        )
                        .onLongPressGesture(minimumDuration: 0.7) {
                            withAnimation(.spring(response: 0.35)) {
                                stickers.removeAll { $0.id == sticker.id }
                            }
                            saveStickers()
                        }
                }

                // Placed earned collectibles — drag to move, double-tap or
                // long-press returns them to the drawer
                ForEach(collected.filter { placed[$0.id] != nil }) { item in
                    let frac = placed[item.id] ?? CGPoint(x: 0.5, y: 0.4)
                    StickerView(emoji: item.emoji)
                        .position(x: frac.x * geo.size.width, y: frac.y * geo.size.height)
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.35)) {
                                placed[item.id] = nil
                            }
                            savePositions()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    placed[item.id] = CGPoint(
                                        x: min(max(value.location.x / geo.size.width, 0.05), 0.95),
                                        y: min(max(value.location.y / geo.size.height, 0.08), 0.85)
                                    )
                                }
                                .onEnded { _ in savePositions() }
                        )
                        .onLongPressGesture(minimumDuration: 0.7) {
                            withAnimation(.spring(response: 0.35)) {
                                placed[item.id] = nil
                            }
                            savePositions()
                        }
                }

                // Bottom drawer: fixed sticker palette + earned treasures
                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        // Scene picker — seven backdrops to decorate
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(NightSkyScene.allCases) { candidate in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            scene = candidate
                                        }
                                        saveScene()
                                    } label: {
                                        VStack(spacing: 3) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: candidate.swatchColors,
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    )
                                                    .frame(width: 34, height: 34)
                                                Text(candidate.badge)
                                                    .font(.system(size: 14))
                                            }
                                            .overlay(
                                                Circle().stroke(
                                                    scene == candidate ? Color.white : Color.white.opacity(0.2),
                                                    lineWidth: scene == candidate ? 2 : 1
                                                )
                                            )
                                            Text(candidate.displayName)
                                                .font(.system(size: 9))
                                                .foregroundStyle(.white.opacity(scene == candidate ? 0.95 : 0.55))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("\(candidate.displayName) scene\(scene == candidate ? ", selected" : "")")
                                }
                            }
                            .padding(.horizontal, 14)
                        }

                        Text("Tap to place · drag to move · double-tap to put back")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.65))
                            .padding(.horizontal, 14)

                        // Always-available sticker palette
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(NightSkySticker.palette) { sticker in
                                    Button {
                                        withAnimation(.spring(response: 0.4)) {
                                            stickers.append(
                                                PlacedSticker(
                                                    id: UUID().uuidString,
                                                    type: sticker.id,
                                                    x: Double.random(in: 0.2...0.8),
                                                    y: Double.random(in: 0.15...0.6)
                                                )
                                            )
                                        }
                                        saveStickers()
                                    } label: {
                                        Text(sticker.emoji)
                                            .font(.system(size: 34))
                                            .padding(8)
                                            .background(Circle().fill(Color.white.opacity(0.10)))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 14)
                        }

                        // Earned treasures (collectibles not yet on the canvas)
                        if !drawerItems.isEmpty {
                            Text("Your treasures")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.55))
                                .padding(.horizontal, 14)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(drawerItems) { item in
                                        Button {
                                            withAnimation(.spring(response: 0.4)) {
                                                placed[item.id] = CGPoint(
                                                    x: Double.random(in: 0.25...0.75),
                                                    y: Double.random(in: 0.2...0.6)
                                                )
                                            }
                                            savePositions()
                                        } label: {
                                            Text(item.emoji)
                                                .font(.system(size: 34))
                                                .padding(8)
                                                .background(Circle().fill(Color.white.opacity(0.10)))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 14)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.45))
                }
            }
        }
        .navigationTitle("Lumi's Night Sky")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if !loaded { load(); loaded = true } }
    }

    // MARK: Sticker helpers

    private func updateSticker(_ id: String, x: Double, y: Double) {
        guard let idx = stickers.firstIndex(where: { $0.id == id }) else { return }
        stickers[idx].x = x
        stickers[idx].y = y
    }

    // MARK: Persistence (per child)

    private func load() {
        loadPositions()
        loadStickers()
        loadScene()
    }

    // Backdrop scene — a plain string, missing/unknown falls back to starry.
    private func loadScene() {
        guard let raw = UserDefaults.standard.string(forKey: sceneKey),
              let saved = NightSkyScene(rawValue: raw) else { return }
        scene = saved
    }

    private func saveScene() {
        UserDefaults.standard.set(scene.rawValue, forKey: sceneKey)
        CloudSync.mirror(scene.rawValue, forKey: sceneKey)
    }

    // Earned collectibles — UNCHANGED store + shape, so old saves still load.
    private func loadPositions() {
        guard let data = UserDefaults.standard.data(forKey: positionsKey),
              let raw = try? JSONDecoder().decode([String: [Double]].self, from: data) else { return }
        placed = raw.compactMapValues { v in
            v.count == 2 ? CGPoint(x: v[0], y: v[1]) : nil
        }
    }

    private func savePositions() {
        let raw = placed.mapValues { [Double($0.x), Double($0.y)] }
        if let data = try? JSONEncoder().encode(raw) {
            UserDefaults.standard.set(data, forKey: positionsKey)
            CloudSync.mirror(data, forKey: positionsKey)
        }
    }

    // Fixed-palette stickers — PARALLEL store, degrades to empty if absent.
    private func loadStickers() {
        guard let data = UserDefaults.standard.data(forKey: stickersKey),
              let decoded = try? JSONDecoder().decode([PlacedSticker].self, from: data) else { return }
        stickers = decoded
    }

    private func saveStickers() {
        if let data = try? JSONEncoder().encode(stickers) {
            UserDefaults.standard.set(data, forKey: stickersKey)
            CloudSync.mirror(data, forKey: stickersKey)
        }
    }
}

// MARK: - Backdrop scenes

/// The seven backdrops a child can decorate. All procedural (gradient +
/// simple shapes), all calm and dim enough that the glowing stickers pop.
enum NightSkyScene: String, CaseIterable, Identifiable {
    case starryNight = "starry"
    case sunset      = "sunset"
    case ocean       = "ocean"
    case meadow      = "meadow"
    case cottonCandy = "candy"
    case rainbow     = "rainbow"
    case snowy       = "snow"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .starryNight: return "Starry"
        case .sunset:      return "Sunset"
        case .ocean:       return "Ocean"
        case .meadow:      return "Meadow"
        case .cottonCandy: return "Candy"
        case .rainbow:     return "Rainbow"
        case .snowy:       return "Snowy"
        }
    }

    /// Tiny emoji shown on the picker swatch so pre-readers can choose.
    var badge: String {
        switch self {
        case .starryNight: return "✨"
        case .sunset:      return "🌅"
        case .ocean:       return "🐟"
        case .meadow:      return "🦗"
        case .cottonCandy: return "🍭"
        case .rainbow:     return "🌈"
        case .snowy:       return "❄️"
        }
    }

    /// Sky gradient, top to bottom. Also used for the picker swatch.
    var swatchColors: [Color] {
        switch self {
        case .starryNight:
            return [Color(red: 0.03, green: 0.09, blue: 0.12),
                    Color(red: 0.10, green: 0.19, blue: 0.20)]
        case .sunset:
            return [Color(red: 0.16, green: 0.09, blue: 0.26),
                    Color(red: 0.55, green: 0.22, blue: 0.30),
                    Color(red: 0.93, green: 0.56, blue: 0.29)]
        case .ocean:
            return [Color(red: 0.02, green: 0.16, blue: 0.26),
                    Color(red: 0.03, green: 0.27, blue: 0.38),
                    Color(red: 0.05, green: 0.38, blue: 0.45)]
        case .meadow:
            return [Color(red: 0.07, green: 0.14, blue: 0.26),
                    Color(red: 0.12, green: 0.24, blue: 0.30),
                    Color(red: 0.13, green: 0.30, blue: 0.22)]
        case .cottonCandy:
            return [Color(red: 0.36, green: 0.22, blue: 0.44),
                    Color(red: 0.62, green: 0.33, blue: 0.52),
                    Color(red: 0.83, green: 0.51, blue: 0.60)]
        case .rainbow:
            return [Color(red: 0.10, green: 0.18, blue: 0.36),
                    Color(red: 0.19, green: 0.30, blue: 0.50)]
        case .snowy:
            return [Color(red: 0.07, green: 0.12, blue: 0.24),
                    Color(red: 0.15, green: 0.23, blue: 0.36)]
        }
    }
}

/// Draws the six non-starry scenes: the sky gradient plus a few simple,
/// seeded decorations in one static Canvas — same zero-cost approach as the
/// Home deep star field.
private struct NightSkySceneBackdrop: View {
    let scene: NightSkyScene

    var body: some View {
        ZStack {
            LinearGradient(colors: scene.swatchColors, startPoint: .top, endPoint: .bottom)

            Canvas { context, size in
                var rng = SeededRandom(seed: 7)
                switch scene {
                case .starryNight:
                    break // handled by StarryNightBackground

                case .sunset:
                    // A big soft sun low on the horizon + a few dusk stars
                    let sun = CGRect(x: size.width * 0.30, y: size.height * 0.52,
                                     width: size.width * 0.40, height: size.width * 0.40)
                    context.fill(Path(ellipseIn: sun.insetBy(dx: -40, dy: -40)),
                                 with: .color(Color(red: 1.0, green: 0.75, blue: 0.40).opacity(0.18)))
                    context.fill(Path(ellipseIn: sun),
                                 with: .color(Color(red: 1.0, green: 0.80, blue: 0.45).opacity(0.45)))
                    for _ in 0..<25 {
                        dot(&context, &rng, size, yRange: 0...0.4, maxD: 1.8,
                            color: .white, maxOpacity: 0.5)
                    }

                case .ocean:
                    // Rising bubbles and gentle seafloor light shafts
                    for _ in 0..<35 {
                        let x = rng.next() * size.width
                        let y = rng.next() * size.height
                        let d = 3 + rng.next() * 9
                        context.stroke(
                            Path(ellipseIn: CGRect(x: x, y: y, width: d, height: d)),
                            with: .color(.white.opacity(0.10 + rng.next() * 0.15)),
                            lineWidth: 1
                        )
                    }
                    for i in 0..<3 {
                        let x = size.width * (0.2 + 0.3 * Double(i))
                        var shaft = Path()
                        shaft.move(to: CGPoint(x: x, y: 0))
                        shaft.addLine(to: CGPoint(x: x + 60, y: 0))
                        shaft.addLine(to: CGPoint(x: x + 140, y: size.height))
                        shaft.addLine(to: CGPoint(x: x + 40, y: size.height))
                        shaft.closeSubpath()
                        context.fill(shaft, with: .color(.white.opacity(0.04)))
                    }

                case .meadow:
                    // Rolling hills + drifting fireflies
                    let hill1 = CGRect(x: -size.width * 0.3, y: size.height * 0.78,
                                       width: size.width * 1.1, height: size.height * 0.5)
                    let hill2 = CGRect(x: size.width * 0.3, y: size.height * 0.84,
                                       width: size.width * 1.1, height: size.height * 0.5)
                    context.fill(Path(ellipseIn: hill1),
                                 with: .color(Color(red: 0.10, green: 0.30, blue: 0.20).opacity(0.9)))
                    context.fill(Path(ellipseIn: hill2),
                                 with: .color(Color(red: 0.08, green: 0.24, blue: 0.16).opacity(0.9)))
                    for _ in 0..<14 {
                        dot(&context, &rng, size, yRange: 0.35...0.85, maxD: 3.0,
                            color: Color(red: 1.0, green: 0.9, blue: 0.4), maxOpacity: 0.7)
                    }
                    for _ in 0..<20 {
                        dot(&context, &rng, size, yRange: 0...0.3, maxD: 1.6,
                            color: .white, maxOpacity: 0.5)
                    }

                case .cottonCandy:
                    // Fluffy pastel clouds
                    for _ in 0..<7 {
                        let cx = rng.next() * size.width
                        let cy = (0.15 + rng.next() * 0.6) * size.height
                        let w = 70 + rng.next() * 110
                        cloud(&context, center: CGPoint(x: cx, y: cy), width: w,
                              color: .white.opacity(0.10 + rng.next() * 0.10))
                    }

                case .rainbow:
                    // Soft pastel arcs rising over two little clouds
                    let bands: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
                    // Center low but radius generous, so the arc crests well
                    // above the sticker drawer
                    let center = CGPoint(x: size.width * 0.5, y: size.height * 0.78)
                    for (i, band) in bands.enumerated() {
                        let radius = size.width * 0.60 - Double(i) * 16
                        var arc = Path()
                        arc.addArc(center: center, radius: radius,
                                   startAngle: .degrees(180), endAngle: .degrees(360),
                                   clockwise: false)
                        context.stroke(arc, with: .color(band.opacity(0.30)), lineWidth: 12)
                    }
                    cloud(&context, center: CGPoint(x: size.width * 0.12, y: size.height * 0.62),
                          width: 90, color: .white.opacity(0.16))
                    cloud(&context, center: CGPoint(x: size.width * 0.88, y: size.height * 0.60),
                          width: 100, color: .white.opacity(0.16))

                case .snowy:
                    // Falling snow + a soft snowy ground
                    let ground = CGRect(x: -40, y: size.height * 0.86,
                                        width: size.width + 80, height: size.height * 0.4)
                    context.fill(Path(ellipseIn: ground), with: .color(.white.opacity(0.18)))
                    for _ in 0..<60 {
                        dot(&context, &rng, size, yRange: 0...0.95, maxD: 3.2,
                            color: .white, maxOpacity: 0.65)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    /// One seeded dot — stars, fireflies, snowflakes.
    private func dot(_ context: inout GraphicsContext, _ rng: inout SeededRandom,
                     _ size: CGSize, yRange: ClosedRange<Double>, maxD: Double,
                     color: Color, maxOpacity: Double) {
        let x = rng.next() * size.width
        let y = (yRange.lowerBound + rng.next() * (yRange.upperBound - yRange.lowerBound)) * size.height
        let d = 0.8 + rng.next() * maxD
        context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: d, height: d)),
                     with: .color(color.opacity(0.15 + rng.next() * (maxOpacity - 0.15))))
    }

    /// A puffy three-lobe cloud.
    private func cloud(_ context: inout GraphicsContext, center: CGPoint,
                       width: Double, color: Color) {
        let h = width * 0.42
        context.fill(Path(ellipseIn: CGRect(x: center.x - width / 2, y: center.y - h / 2,
                                            width: width, height: h)), with: .color(color))
        context.fill(Path(ellipseIn: CGRect(x: center.x - width * 0.28, y: center.y - h * 0.95,
                                            width: width * 0.5, height: h * 0.9)), with: .color(color))
        context.fill(Path(ellipseIn: CGRect(x: center.x - width * 0.05, y: center.y - h * 0.75,
                                            width: width * 0.42, height: h * 0.8)), with: .color(color))
    }
}

// MARK: - Sticker model

/// A type in the always-available palette.
private struct NightSkySticker: Identifiable {
    let id: String
    let emoji: String

    static let palette: [NightSkySticker] = [
        NightSkySticker(id: "star",     emoji: "⭐"),
        NightSkySticker(id: "moon",     emoji: "🌙"),
        NightSkySticker(id: "lumi",     emoji: "🐝"),
        NightSkySticker(id: "cloud",    emoji: "☁️"),
        NightSkySticker(id: "heart",    emoji: "💛"),
        NightSkySticker(id: "sparkle",  emoji: "✨"),
        NightSkySticker(id: "rainbow",  emoji: "🌈"),
        NightSkySticker(id: "shooting", emoji: "🌠")
    ]

    static func emoji(for typeID: String) -> String {
        palette.first(where: { $0.id == typeID })?.emoji ?? "⭐"
    }
}

/// One placed palette sticker. Position stored as plain Doubles (fractions
/// of the canvas) so Codable round-trips cleanly without CGPoint quirks.
private struct PlacedSticker: Identifiable, Codable {
    let id: String      // unique instance id (UUID string)
    let type: String    // palette type id (e.g. "star")
    var x: Double       // 0...1 fraction of width
    var y: Double       // 0...1 fraction of height

    var emoji: String { NightSkySticker.emoji(for: type) }
}

private struct StickerView: View {
    let emoji: String

    var body: some View {
        Text(emoji)
            .font(.system(size: 44))
            .shadow(color: .yellow.opacity(0.45), radius: 8)
            .contentShape(Circle())
    }
}
