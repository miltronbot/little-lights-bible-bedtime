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
    @State private var loaded = false

    private var positionsKey: String {
        ProfileScope.key("nightSky.positions", profile: appSettings.activeChildName)
    }

    private var stickersKey: String {
        ProfileScope.key("nightSky.stickers", profile: appSettings.activeChildName)
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
                StarryNightBackground(alwaysStarry: true)
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

                // Placed palette stickers — draggable, long-press removes.
                ForEach(stickers) { sticker in
                    StickerView(emoji: sticker.emoji)
                        .position(x: sticker.x * geo.size.width, y: sticker.y * geo.size.height)
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

                // Placed earned collectibles — draggable, long-press returns to drawer
                ForEach(collected.filter { placed[$0.id] != nil }) { item in
                    let frac = placed[item.id] ?? CGPoint(x: 0.5, y: 0.4)
                    StickerView(emoji: item.emoji)
                        .position(x: frac.x * geo.size.width, y: frac.y * geo.size.height)
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
                        Text("Tap to place · drag to move · hold to put back")
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
