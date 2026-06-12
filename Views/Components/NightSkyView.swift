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
    /// Drawer can tuck away so the whole scene is usable for decorating.
    @State private var drawerOpen = true
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
                                        y: min(max(value.location.y / geo.size.height, 0.08), 0.92)
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
                                        y: min(max(value.location.y / geo.size.height, 0.08), 0.92)
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

                // Bottom drawer: fixed sticker palette + earned treasures.
                // Tucks away (chevron / floating button) so the WHOLE scene
                // is reachable while decorating.
                VStack {
                    Spacer()
                    if drawerOpen {
                    VStack(alignment: .leading, spacing: 8) {
                        // Tuck-away handle
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.35)) {
                                    drawerOpen = false
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(.horizontal, 18)
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Hide sticker drawer")
                            Spacer()
                        }

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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        // Floating reopen button keeps the scene clear
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.35)) {
                                    drawerOpen = true
                                }
                            } label: {
                                Image(systemName: "square.grid.2x2.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .padding(14)
                                    .background(Circle().fill(Color.black.opacity(0.5)))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Show sticker drawer")
                            .padding(.trailing, 16)
                            .padding(.bottom, 12)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .navigationTitle(scene.title)
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

    /// Screen title — follows the chosen environment.
    var title: String {
        switch self {
        case .starryNight: return "Lumi's Night Sky"
        case .sunset:      return "Lumi's Sunset"
        case .ocean:       return "Lumi's Ocean"
        case .meadow:      return "Lumi's Meadow"
        case .cottonCandy: return "Lumi's Candy Sky"
        case .rainbow:     return "Lumi's Rainbow"
        case .snowy:       return "Lumi's Snowy Night"
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

/// Draws the six non-starry scenes: a sky gradient plus layered, seeded
/// decorations in one static Canvas — same zero-cost approach as the Home
/// deep star field. Each scene is composed so it clearly reads as its
/// environment (waves and fish in the ocean, grassy hills and flowers in
/// the meadow, a snowman and pines in the snow…) while staying dim enough
/// that the glowing stickers pop.
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
                    drawSunset(&context, &rng, size)
                case .ocean:
                    drawOcean(&context, &rng, size)
                case .meadow:
                    drawMeadow(&context, &rng, size)
                case .cottonCandy:
                    drawCottonCandy(&context, &rng, size)
                case .rainbow:
                    drawRainbow(&context, size)
                case .snowy:
                    drawSnowy(&context, &rng, size)
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: Scenes

    /// Sun sinking into water: glowing sun, streaky clouds, a dark sea band
    /// with a shimmering sun path, and a few birds heading home.
    private func drawSunset(_ c: inout GraphicsContext, _ rng: inout SeededRandom, _ size: CGSize) {
        let horizon = size.height * 0.62

        // Dusk stars high up
        for _ in 0..<20 {
            dot(&c, &rng, size, yRange: 0...0.25, maxD: 1.8, color: .white, maxOpacity: 0.5)
        }

        // Sun halo + disc, sitting ON the horizon
        let sunR = size.width * 0.17
        let sunCenter = CGPoint(x: size.width * 0.5, y: horizon - sunR * 0.4)
        c.fill(Path(ellipseIn: rect(center: sunCenter, r: sunR * 2.1)),
               with: .color(Color(red: 1.0, green: 0.72, blue: 0.38).opacity(0.16)))
        c.fill(Path(ellipseIn: rect(center: sunCenter, r: sunR)),
               with: .color(Color(red: 1.0, green: 0.82, blue: 0.46).opacity(0.85)))

        // Long streaky clouds crossing the sun
        for i in 0..<4 {
            let y = size.height * (0.30 + 0.09 * Double(i)) + (rng.next() - 0.5) * 14
            let w = size.width * (0.36 + rng.next() * 0.4)
            let x = rng.next() * (size.width - w)
            let h = 9.0 + rng.next() * 8
            c.fill(Path(roundedRect: CGRect(x: x, y: y, width: w, height: h), cornerRadius: h / 2),
                   with: .color(Color(red: 0.45, green: 0.18, blue: 0.30).opacity(0.45)))
        }

        // The sea: dark band below the horizon with a shimmering sun path
        c.fill(Path(CGRect(x: 0, y: horizon, width: size.width, height: size.height - horizon)),
               with: .color(Color(red: 0.13, green: 0.08, blue: 0.22).opacity(0.92)))
        for i in 0..<9 {
            let t = Double(i) / 9.0
            let y = horizon + 12 + t * (size.height - horizon - 40)
            let w = sunR * (0.9 - t * 0.5) * (1.4 + rng.next() * 0.5)
            c.fill(Path(roundedRect: CGRect(x: size.width * 0.5 - w / 2, y: y, width: w, height: 4),
                        cornerRadius: 2),
                   with: .color(Color(red: 1.0, green: 0.75, blue: 0.42).opacity(0.30 - t * 0.2)))
        }

        // Birds flying home
        for _ in 0..<4 {
            bird(&c, at: CGPoint(x: (0.12 + rng.next() * 0.7) * size.width,
                                 y: (0.16 + rng.next() * 0.22) * size.height),
                 wing: 7 + rng.next() * 5)
        }
    }

    /// Under the sea: layered wave bands, fish swimming by, seaweed and sand.
    private func drawOcean(_ c: inout GraphicsContext, _ rng: inout SeededRandom, _ size: CGSize) {
        // Light shafts from the surface
        for i in 0..<3 {
            let x = size.width * (0.15 + 0.32 * Double(i))
            var shaft = Path()
            shaft.move(to: CGPoint(x: x, y: 0))
            shaft.addLine(to: CGPoint(x: x + 55, y: 0))
            shaft.addLine(to: CGPoint(x: x + 150, y: size.height))
            shaft.addLine(to: CGPoint(x: x + 45, y: size.height))
            shaft.closeSubpath()
            c.fill(shaft, with: .color(.white.opacity(0.05)))
        }

        // Rolling wave bands near the top (we're just under the surface)
        for band in 0..<3 {
            let baseY = size.height * (0.06 + 0.045 * Double(band))
            var wave = Path()
            wave.move(to: CGPoint(x: 0, y: baseY))
            let waveLen = size.width / 4.5
            var x = 0.0
            while x < size.width {
                wave.addQuadCurve(
                    to: CGPoint(x: x + waveLen, y: baseY),
                    control: CGPoint(x: x + waveLen / 2, y: baseY - 16)
                )
                x += waveLen
            }
            wave.addLine(to: CGPoint(x: size.width, y: 0))
            wave.addLine(to: CGPoint(x: 0, y: 0))
            wave.closeSubpath()
            c.fill(wave, with: .color(.white.opacity(0.07 - Double(band) * 0.015)))
        }

        // Fish swimming in small schools
        for _ in 0..<7 {
            fish(&c, &rng,
                 at: CGPoint(x: (0.1 + rng.next() * 0.8) * size.width,
                             y: (0.25 + rng.next() * 0.45) * size.height),
                 length: 16 + rng.next() * 14,
                 flip: rng.next() > 0.5)
        }

        // Bubbles drifting up
        for _ in 0..<22 {
            let x = rng.next() * size.width
            let y = rng.next() * size.height
            let d = 3 + rng.next() * 8
            c.stroke(Path(ellipseIn: CGRect(x: x, y: y, width: d, height: d)),
                     with: .color(.white.opacity(0.10 + rng.next() * 0.15)), lineWidth: 1)
        }

        // Sandy floor + swaying seaweed
        let sandTop = size.height * 0.88
        c.fill(Path(ellipseIn: CGRect(x: -60, y: sandTop, width: size.width + 120, height: size.height * 0.3)),
               with: .color(Color(red: 0.55, green: 0.45, blue: 0.30).opacity(0.45)))
        for _ in 0..<6 {
            let baseX = rng.next() * size.width
            let h = 36 + rng.next() * 50
            var weed = Path()
            weed.move(to: CGPoint(x: baseX, y: sandTop + 14))
            weed.addQuadCurve(to: CGPoint(x: baseX + 6, y: sandTop + 14 - h),
                              control: CGPoint(x: baseX - 16 + rng.next() * 32, y: sandTop + 14 - h / 2))
            c.stroke(weed, with: .color(Color(red: 0.15, green: 0.50, blue: 0.35).opacity(0.6)),
                     style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }
    }

    /// A twilight meadow: moon, layered grassy hills, grass tufts, flowers
    /// and fireflies.
    private func drawMeadow(_ c: inout GraphicsContext, _ rng: inout SeededRandom, _ size: CGSize) {
        // Crescent moon + a few stars
        let moonCenter = CGPoint(x: size.width * 0.78, y: size.height * 0.14)
        c.fill(Path(ellipseIn: rect(center: moonCenter, r: 26)),
               with: .color(Color(red: 0.96, green: 0.93, blue: 0.78).opacity(0.85)))
        c.fill(Path(ellipseIn: rect(center: CGPoint(x: moonCenter.x - 11, y: moonCenter.y - 7), r: 22)),
               with: .color(Color(red: 0.07, green: 0.14, blue: 0.26)))
        for _ in 0..<18 {
            dot(&c, &rng, size, yRange: 0...0.3, maxD: 1.8, color: .white, maxOpacity: 0.55)
        }

        // Layered hills filling the lower half — unmistakably a meadow
        let hillColors = [
            Color(red: 0.16, green: 0.34, blue: 0.24).opacity(0.95),
            Color(red: 0.12, green: 0.28, blue: 0.19).opacity(0.95),
            Color(red: 0.09, green: 0.22, blue: 0.15),
        ]
        let hillTops = [0.52, 0.62, 0.74]
        for (i, top) in hillTops.enumerated() {
            var hill = Path()
            let y = size.height * top
            hill.move(to: CGPoint(x: 0, y: size.height))
            hill.addLine(to: CGPoint(x: 0, y: y + 40))
            hill.addQuadCurve(to: CGPoint(x: size.width, y: y + (i % 2 == 0 ? 60 : 10)),
                              control: CGPoint(x: size.width * (i % 2 == 0 ? 0.35 : 0.65), y: y - 50))
            hill.addLine(to: CGPoint(x: size.width, y: size.height))
            hill.closeSubpath()
            c.fill(hill, with: .color(hillColors[i]))
        }

        // Grass tufts along the front hill
        for _ in 0..<26 {
            let baseX = rng.next() * size.width
            let baseY = size.height * (0.80 + rng.next() * 0.16)
            for blade in 0..<3 {
                let lean = Double(blade - 1) * 5.0
                var grass = Path()
                grass.move(to: CGPoint(x: baseX, y: baseY))
                grass.addQuadCurve(to: CGPoint(x: baseX + lean, y: baseY - 13 - rng.next() * 8),
                                   control: CGPoint(x: baseX + lean / 2, y: baseY - 8))
                c.stroke(grass, with: .color(Color(red: 0.25, green: 0.50, blue: 0.30).opacity(0.8)),
                         style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
            }
        }

        // Little flowers dotted through the grass
        for _ in 0..<10 {
            let center = CGPoint(x: rng.next() * size.width,
                                 y: size.height * (0.68 + rng.next() * 0.26))
            let petal = [Color.pink, Color.yellow, Color.white, Color.orange][Int(rng.next() * 3.99)]
            for angle in stride(from: 0.0, to: 360.0, by: 72.0) {
                let rad = angle * .pi / 180
                c.fill(Path(ellipseIn: rect(center: CGPoint(x: center.x + cos(rad) * 4,
                                                            y: center.y + sin(rad) * 4), r: 2.6)),
                       with: .color(petal.opacity(0.75)))
            }
            c.fill(Path(ellipseIn: rect(center: center, r: 2.2)),
                   with: .color(.yellow.opacity(0.9)))
        }

        // Fireflies above the grass
        for _ in 0..<12 {
            let center = CGPoint(x: rng.next() * size.width,
                                 y: size.height * (0.45 + rng.next() * 0.35))
            c.fill(Path(ellipseIn: rect(center: center, r: 4.5)),
                   with: .color(Color(red: 1.0, green: 0.9, blue: 0.4).opacity(0.18)))
            c.fill(Path(ellipseIn: rect(center: center, r: 1.8)),
                   with: .color(Color(red: 1.0, green: 0.92, blue: 0.5).opacity(0.8)))
        }
    }

    /// Cotton-candy sky: big soft pastel clouds stacked like spun sugar,
    /// with sprinkle stars.
    private func drawCottonCandy(_ c: inout GraphicsContext, _ rng: inout SeededRandom, _ size: CGSize) {
        // Sprinkle stars
        for _ in 0..<24 {
            dot(&c, &rng, size, yRange: 0...0.5, maxD: 2.2, color: .white, maxOpacity: 0.6)
        }

        // Stacked candy clouds in alternating pinks and whites
        let tones: [Color] = [
            Color(red: 1.0, green: 0.75, blue: 0.85).opacity(0.30),
            Color.white.opacity(0.20),
            Color(red: 0.85, green: 0.65, blue: 0.95).opacity(0.28),
        ]
        for i in 0..<9 {
            let cx = rng.next() * size.width
            let cy = (0.18 + rng.next() * 0.62) * size.height
            let w = 80 + rng.next() * 130
            cloud(&c, center: CGPoint(x: cx, y: cy), width: w, color: tones[i % tones.count])
        }

        // A drifting candy-floss swirl
        var swirl = Path()
        swirl.move(to: CGPoint(x: size.width * 0.18, y: size.height * 0.74))
        swirl.addCurve(to: CGPoint(x: size.width * 0.85, y: size.height * 0.70),
                       control1: CGPoint(x: size.width * 0.38, y: size.height * 0.64),
                       control2: CGPoint(x: size.width * 0.62, y: size.height * 0.80))
        c.stroke(swirl, with: .color(.white.opacity(0.18)),
                 style: StrokeStyle(lineWidth: 18, lineCap: .round))
    }

    /// A rainbow arcing between two clouds, with sparkles beneath it.
    private func drawRainbow(_ c: inout GraphicsContext, _ size: CGSize) {
        let bands: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.78)
        for (i, band) in bands.enumerated() {
            let radius = size.width * 0.60 - Double(i) * 16
            var arc = Path()
            arc.addArc(center: center, radius: radius,
                       startAngle: .degrees(180), endAngle: .degrees(360),
                       clockwise: false)
            c.stroke(arc, with: .color(band.opacity(0.32)), lineWidth: 12)
        }
        cloud(&c, center: CGPoint(x: size.width * 0.5 - size.width * 0.58, y: size.height * 0.78),
              width: 110, color: .white.opacity(0.22))
        cloud(&c, center: CGPoint(x: size.width * 0.5 + size.width * 0.58, y: size.height * 0.78),
              width: 110, color: .white.opacity(0.22))
        var rng = SeededRandom(seed: 11)
        for _ in 0..<26 {
            dot(&c, &rng, size, yRange: 0...0.45, maxD: 2.2, color: .white, maxOpacity: 0.6)
        }
    }

    /// A snowy night: drifts of snow on the ground, frosted pine trees, a
    /// friendly snowman, and falling snow at three depths.
    private func drawSnowy(_ c: inout GraphicsContext, _ rng: inout SeededRandom, _ size: CGSize) {
        // Snowy ground: two soft drifts
        let groundY = size.height * 0.80
        c.fill(Path(ellipseIn: CGRect(x: -80, y: groundY, width: size.width * 0.9, height: size.height * 0.35)),
               with: .color(.white.opacity(0.30)))
        c.fill(Path(ellipseIn: CGRect(x: size.width * 0.35, y: groundY + 26, width: size.width * 0.95, height: size.height * 0.35)),
               with: .color(.white.opacity(0.24)))

        // Frosted pines on the left
        for (i, treeX) in [0.12, 0.24].enumerated() {
            let baseY = groundY + 30 + Double(i) * 8
            let treeH = 95.0 - Double(i) * 18
            let halfW = 30.0 - Double(i) * 5
            let x = treeX * size.width
            for layer in 0..<3 {
                let layerY = baseY - treeH * (0.40 + 0.30 * Double(layer))
                let layerW = halfW * (1.0 - 0.26 * Double(layer))
                var tri = Path()
                tri.move(to: CGPoint(x: x, y: layerY - treeH * 0.30))
                tri.addLine(to: CGPoint(x: x - layerW, y: layerY))
                tri.addLine(to: CGPoint(x: x + layerW, y: layerY))
                tri.closeSubpath()
                c.fill(tri, with: .color(Color(red: 0.16, green: 0.30, blue: 0.30).opacity(0.95)))
                // Snow resting on each layer
                c.fill(Path(ellipseIn: CGRect(x: x - layerW * 0.7, y: layerY - 4, width: layerW * 1.4, height: 7)),
                       with: .color(.white.opacity(0.55)))
            }
        }

        // A friendly snowman on the right
        let snowmanX = size.width * 0.78
        let baseY = groundY + 34
        c.fill(Path(ellipseIn: rect(center: CGPoint(x: snowmanX, y: baseY), r: 26)),
               with: .color(.white.opacity(0.85)))
        c.fill(Path(ellipseIn: rect(center: CGPoint(x: snowmanX, y: baseY - 38), r: 19)),
               with: .color(.white.opacity(0.88)))
        c.fill(Path(ellipseIn: rect(center: CGPoint(x: snowmanX, y: baseY - 66), r: 13)),
               with: .color(.white.opacity(0.92)))
        // Face + buttons
        c.fill(Path(ellipseIn: rect(center: CGPoint(x: snowmanX - 4, y: baseY - 69), r: 1.6)),
               with: .color(.black.opacity(0.7)))
        c.fill(Path(ellipseIn: rect(center: CGPoint(x: snowmanX + 4, y: baseY - 69), r: 1.6)),
               with: .color(.black.opacity(0.7)))
        var carrot = Path()
        carrot.move(to: CGPoint(x: snowmanX, y: baseY - 66))
        carrot.addLine(to: CGPoint(x: snowmanX + 9, y: baseY - 64))
        carrot.addLine(to: CGPoint(x: snowmanX, y: baseY - 62))
        carrot.closeSubpath()
        c.fill(carrot, with: .color(.orange.opacity(0.85)))
        for b in 0..<2 {
            c.fill(Path(ellipseIn: rect(center: CGPoint(x: snowmanX, y: baseY - 42 + Double(b) * 9), r: 1.8)),
                   with: .color(.black.opacity(0.6)))
        }

        // Falling snow at three depths — small/dim far, big/bright near
        for depth in 0..<3 {
            let count = [26, 18, 12][depth]
            let dia = [2.0, 3.4, 5.0][depth]
            let opacity = [0.35, 0.55, 0.8][depth]
            for _ in 0..<count {
                let x = rng.next() * size.width
                let y = rng.next() * size.height * 0.92
                c.fill(Path(ellipseIn: CGRect(x: x, y: y, width: dia, height: dia)),
                       with: .color(.white.opacity(opacity * (0.7 + rng.next() * 0.3))))
            }
        }
    }

    // MARK: Drawing helpers

    private func rect(center: CGPoint, r: Double) -> CGRect {
        CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)
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

    /// A tiny "m"-shaped bird silhouette.
    private func bird(_ context: inout GraphicsContext, at p: CGPoint, wing: Double) {
        var path = Path()
        path.move(to: CGPoint(x: p.x - wing, y: p.y))
        path.addQuadCurve(to: CGPoint(x: p.x, y: p.y),
                          control: CGPoint(x: p.x - wing / 2, y: p.y - wing * 0.8))
        path.addQuadCurve(to: CGPoint(x: p.x + wing, y: p.y),
                          control: CGPoint(x: p.x + wing / 2, y: p.y - wing * 0.8))
        context.stroke(path, with: .color(.black.opacity(0.5)),
                       style: StrokeStyle(lineWidth: 1.6, lineCap: .round))
    }

    /// A simple fish: body ellipse + tail triangle + eye.
    private func fish(_ context: inout GraphicsContext, _ rng: inout SeededRandom,
                      at p: CGPoint, length: Double, flip: Bool) {
        let dir: Double = flip ? -1 : 1
        let bodyW = length
        let bodyH = length * 0.55
        let tone = [Color.orange, Color.yellow, Color.cyan, Color.pink][Int(rng.next() * 3.99)]

        context.fill(Path(ellipseIn: CGRect(x: p.x - bodyW / 2, y: p.y - bodyH / 2,
                                            width: bodyW, height: bodyH)),
                     with: .color(tone.opacity(0.55)))
        var tail = Path()
        tail.move(to: CGPoint(x: p.x - dir * bodyW / 2, y: p.y))
        tail.addLine(to: CGPoint(x: p.x - dir * (bodyW / 2 + length * 0.4), y: p.y - bodyH * 0.45))
        tail.addLine(to: CGPoint(x: p.x - dir * (bodyW / 2 + length * 0.4), y: p.y + bodyH * 0.45))
        tail.closeSubpath()
        context.fill(tail, with: .color(tone.opacity(0.45)))
        context.fill(Path(ellipseIn: CGRect(x: p.x + dir * bodyW * 0.22 - 1.5, y: p.y - bodyH * 0.12,
                                            width: 3, height: 3)),
                     with: .color(.black.opacity(0.6)))
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
