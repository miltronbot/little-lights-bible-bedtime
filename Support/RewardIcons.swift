import SwiftUI
import UIKit

// MARK: - Reward Icons
// Procedural icon system for collectibles and badges. Replaces the plain
// emoji glyphs with SF Symbol compositions on gradient gem/medal backplates
// so rewards feel earned and premium without shipping any image assets.
//
// Collectibles render as round "treasure gems": a radial-gradient disc with
// a glassy highlight, a gold ring when earned, and a tinted symbol.
// Badges render as scalloped "medals" built on the seal.fill symbol.
//
// Every symbol below is verified available on iOS 16/17 (checked against the
// system glyph database). If a name is ever missing at runtime the views fall
// back to the original emoji so nothing can render blank.

struct RewardIconSpec {
    let symbol: String
    let top: Color      // gradient start (lighter, catches the light)
    let bottom: Color   // gradient end (deeper, sets the subject's hue)
}

/// 0xRRGGBB convenience used only by the catalogs below.
private func rgb(_ hex: UInt32) -> Color {
    Color(
        red: Double((hex >> 16) & 0xFF) / 255,
        green: Double((hex >> 8) & 0xFF) / 255,
        blue: Double(hex & 0xFF) / 255
    )
}

enum RewardIconCatalog {
    /// One spec per collectible id (Models/Collectible.swift — 50 total).
    static let collectibles: [String: RewardIconSpec] = [
        "dove":        RewardIconSpec(symbol: "bird.fill",                        top: rgb(0x9BD4F5), bottom: rgb(0x2E6FB2)),
        "sling":       RewardIconSpec(symbol: "lasso",                            top: rgb(0xD9A86C), bottom: rgb(0x8A5A2B)),
        "heart":       RewardIconSpec(symbol: "heart.fill",                       top: rgb(0xF8A1C0), bottom: rgb(0xD33D6E)),
        "lion":        RewardIconSpec(symbol: "cat.fill",                         top: rgb(0xF5C26B), bottom: rgb(0xC07A1F)),
        "flower":      RewardIconSpec(symbol: "camera.macro",                     top: rgb(0xF9C2D8), bottom: rgb(0xB85A9E)),
        "boat":        RewardIconSpec(symbol: "sailboat.fill",                    top: rgb(0x7FD3E0), bottom: rgb(0x1F7A95)),
        "sheep":       RewardIconSpec(symbol: "pawprint.fill",                    top: rgb(0xBFE3A8), bottom: rgb(0x4E8A3C)),
        "star":        RewardIconSpec(symbol: "star.fill",                        top: rgb(0xFFE08A), bottom: rgb(0xD99A1B)),
        "fish":        RewardIconSpec(symbol: "fish.fill",                        top: rgb(0x86C5EA), bottom: rgb(0x195A8C)),
        "basket":      RewardIconSpec(symbol: "basket.fill",                      top: rgb(0xA8D8A0), bottom: rgb(0x3E7D4C)),
        "coat":        RewardIconSpec(symbol: "tshirt.fill",                      top: rgb(0xC79BF2), bottom: rgb(0x7A3BC8)),
        "bread":       RewardIconSpec(symbol: "fork.knife",                       top: rgb(0xF2C98A), bottom: rgb(0xA9682A)),
        "gift":        RewardIconSpec(symbol: "gift.fill",                        top: rgb(0xF59A9A), bottom: rgb(0xC0392B)),
        "angel":       RewardIconSpec(symbol: "sparkles",                         top: rgb(0xFFF1B8), bottom: rgb(0xC9A23B)),
        "tree":        RewardIconSpec(symbol: "tree.fill",                        top: rgb(0x9CD489), bottom: rgb(0x2F7A3D)),
        "hug":         RewardIconSpec(symbol: "figure.2.and.child.holdinghands",  top: rgb(0xF7B27E), bottom: rgb(0xC65F32)),
        "ring":        RewardIconSpec(symbol: "circle.circle",                    top: rgb(0xF6D788), bottom: rgb(0xB8860B)),
        "crown":       RewardIconSpec(symbol: "crown.fill",                       top: rgb(0xC9A2E8), bottom: rgb(0x6A2D9C)),
        "trumpet":     RewardIconSpec(symbol: "horn.blast.fill",                  top: rgb(0xF0C36B), bottom: rgb(0xA8761C)),
        "breeze":      RewardIconSpec(symbol: "leaf.fill",                        top: rgb(0xB6E3A1), bottom: rgb(0x4D9A45)),
        "lamp":        RewardIconSpec(symbol: "lamp.table.fill",                  top: rgb(0xFAD489), bottom: rgb(0xB87A1E)),
        "stars":       RewardIconSpec(symbol: "moon.stars.fill",                  top: rgb(0x9FA8E8), bottom: rgb(0x3B3F8C)),
        "wheat":       RewardIconSpec(symbol: "laurel.leading",                   top: rgb(0xEFD27E), bottom: rgb(0xA8821F)),
        "bush":        RewardIconSpec(symbol: "flame.fill",                       top: rgb(0xF8A65C), bottom: rgb(0xC0392B)),
        "wave":        RewardIconSpec(symbol: "water.waves",                      top: rgb(0x8AD4E8), bottom: rgb(0x1F6FA8)),
        "ladder":      RewardIconSpec(symbol: "stairs",                           top: rgb(0xC4B5F0), bottom: rgb(0x6A4FB8)),
        "candle":      RewardIconSpec(symbol: "light.beacon.max.fill",            top: rgb(0xFAD06B), bottom: rgb(0xC2701D)),
        "raven":       RewardIconSpec(symbol: "bird",                             top: rgb(0x9A9AC4), bottom: rgb(0x3A3A5C)),
        "friends":     RewardIconSpec(symbol: "person.3.fill",                    top: rgb(0x86D8C0), bottom: rgb(0x1F8A6C)),
        "prayer":      RewardIconSpec(symbol: "hands.sparkles.fill",              top: rgb(0xBFC8F2), bottom: rgb(0x5C6BC0)),
        "blossom":     RewardIconSpec(symbol: "fanblades.fill",                   top: rgb(0xF796A8), bottom: rgb(0xC2185B)),
        "brothers":    RewardIconSpec(symbol: "figure.2.arms.open",               top: rgb(0xE8B873), bottom: rgb(0x9C6A2F)),
        "tambourine":  RewardIconSpec(symbol: "music.quarternote.3",              top: rgb(0xE8A2D8), bottom: rgb(0x9C2D8C)),
        "brick":       RewardIconSpec(symbol: "square.stack.3d.up.fill",          top: rgb(0xE09A7A), bottom: rgb(0x9C4A2A)),
        "song":        RewardIconSpec(symbol: "music.note",                       top: rgb(0x9AD8E8), bottom: rgb(0x2D7A9C)),
        "scroll":      RewardIconSpec(symbol: "scroll.fill",                      top: rgb(0xEAD3A2), bottom: rgb(0x9C7A3A)),
        "footprints":  RewardIconSpec(symbol: "shoeprints.fill",                  top: rgb(0xA8E0D8), bottom: rgb(0x2D8C8C)),
        "seed":        RewardIconSpec(symbol: "leaf.circle.fill",                 top: rgb(0xACE09A), bottom: rgb(0x3D8C2D)),
        "sunrise":     RewardIconSpec(symbol: "sunrise.fill",                     top: rgb(0xFAC078), bottom: rgb(0xD2691E)),
        "sunflower":   RewardIconSpec(symbol: "sun.max.fill",                     top: rgb(0xFADF6B), bottom: rgb(0xC8941A)),
        "teapot":      RewardIconSpec(symbol: "cup.and.saucer.fill",              top: rgb(0xE0B8A2), bottom: rgb(0x8C5A3D)),
        "thanks":      RewardIconSpec(symbol: "heart.circle.fill",                top: rgb(0xFAD978), bottom: rgb(0xC8861A)),
        "olive":       RewardIconSpec(symbol: "laurel.trailing",                  top: rgb(0xC2D88A), bottom: rgb(0x6B8C2D)),
        "dawn":        RewardIconSpec(symbol: "sun.horizon.fill",                 top: rgb(0xF8B88A), bottom: rgb(0xC2566A)),
        "anchor":      RewardIconSpec(symbol: "lifepreserver.fill",               top: rgb(0x8AB8E8), bottom: rgb(0x1F4E8C)),
        "coins":       RewardIconSpec(symbol: "circlebadge.2.fill",               top: rgb(0xF0C878), bottom: rgb(0xA8701E)),
        "water":       RewardIconSpec(symbol: "drop.fill",                        top: rgb(0x8AD0F0), bottom: rgb(0x1E6FB8)),
        "treasure":    RewardIconSpec(symbol: "diamond.fill",                     top: rgb(0x9AD8F0), bottom: rgb(0x3D5AB8)),
        "basin":       RewardIconSpec(symbol: "humidity.fill",                    top: rgb(0x9AD8D0), bottom: rgb(0x2D7A8C)),
        "lantern":     RewardIconSpec(symbol: "rays",                             top: rgb(0xFFE89A), bottom: rgb(0xC89018)),
    ]

    /// One spec per badge id (ReadingStreak.badgeInfo — 27 total).
    static let badges: [String: RewardIconSpec] = [
        // Story-count milestones
        "first-story":        RewardIconSpec(symbol: "sparkle",               top: rgb(0xFFE08A), bottom: rgb(0xD99A1B)),
        "little-listener":    RewardIconSpec(symbol: "headphones",            top: rgb(0x9AC8F0), bottom: rgb(0x3D6AB8)),
        "bookworm":           RewardIconSpec(symbol: "book.fill",             top: rgb(0xA8D89A), bottom: rgb(0x3D7A3D)),
        "story-explorer":     RewardIconSpec(symbol: "map.fill",              top: rgb(0xF0C078), bottom: rgb(0xA8682A)),
        "tale-traveler":      RewardIconSpec(symbol: "backpack.fill",         top: rgb(0xE0A878), bottom: rgb(0x8C5A2D)),
        "story-collector":    RewardIconSpec(symbol: "books.vertical.fill",   top: rgb(0xC0A2E0), bottom: rgb(0x6A3D9C)),
        "bible-scholar":      RewardIconSpec(symbol: "graduationcap.fill",    top: rgb(0x9AB8D8), bottom: rgb(0x2D4A7A)),
        "scripture-star":     RewardIconSpec(symbol: "sparkles",              top: rgb(0xFAE08A), bottom: rgb(0xC8941A)),
        "wisdom-seeker":      RewardIconSpec(symbol: "lightbulb.fill",        top: rgb(0xFAD96B), bottom: rgb(0xB8821A)),
        "faith-filled":       RewardIconSpec(symbol: "heart.fill",            top: rgb(0xF8A1C0), bottom: rgb(0xC23D6E)),
        "almost-home":        RewardIconSpec(symbol: "house.fill",            top: rgb(0xF0B89A), bottom: rgb(0xA85A3D)),
        "master-reader":      RewardIconSpec(symbol: "crown.fill",            top: rgb(0xFAD06B), bottom: rgb(0xB8860B)),

        // Streak milestones
        "two-night-twinkle":  RewardIconSpec(symbol: "moon.fill",             top: rgb(0xB8C2F0), bottom: rgb(0x4A4F9C)),
        "3-day-streak":       RewardIconSpec(symbol: "flame.fill",            top: rgb(0xF8A65C), bottom: rgb(0xC0392B)),
        "high-five":          RewardIconSpec(symbol: "hand.raised.fill",      top: rgb(0xF8C88A), bottom: rgb(0xC2701D)),
        "week-warrior":       RewardIconSpec(symbol: "bolt.fill",             top: rgb(0xFAE06B), bottom: rgb(0xC8861A)),
        "perfect-ten":        RewardIconSpec(symbol: "10.circle.fill",        top: rgb(0x9AD8C0), bottom: rgb(0x2D8C6C)),
        "faithful-reader":    RewardIconSpec(symbol: "hands.clap.fill",       top: rgb(0xF0A8B8), bottom: rgb(0xB83D5C)),
        "habit-hero":         RewardIconSpec(symbol: "calendar",              top: rgb(0x9AC0E8), bottom: rgb(0x2D5A9C)),
        "devotion-champion":  RewardIconSpec(symbol: "trophy.fill",           top: rgb(0xFAD478), bottom: rgb(0xB8821A)),
        "diamond-devotion":   RewardIconSpec(symbol: "diamond.fill",          top: rgb(0xA8E0F0), bottom: rgb(0x3D6AC8)),
        "hundred-night-hero": RewardIconSpec(symbol: "medal.fill",            top: rgb(0xF0C878), bottom: rgb(0xA8701E)),

        // Sleep Star milestones
        "star-catcher":       RewardIconSpec(symbol: "wand.and.stars",        top: rgb(0xC8B2F0), bottom: rgb(0x5C3DA8)),
        "star-gazer":         RewardIconSpec(symbol: "binoculars.fill",       top: rgb(0x9AB8E0), bottom: rgb(0x2D4A8C)),
        "sky-full-of-stars":  RewardIconSpec(symbol: "moon.stars.fill",       top: rgb(0x9FA8E8), bottom: rgb(0x3B3F8C)),

        // Moment badges
        "bedtime-believer":   RewardIconSpec(symbol: "bed.double.fill",       top: rgb(0xB2A8E8), bottom: rgb(0x4A3D8C)),
        "weekend-wonder":     RewardIconSpec(symbol: "sun.max.fill",          top: rgb(0xFADF6B), bottom: rgb(0xC8941A)),

        // Completion rewards
        "treasure-keeper":    RewardIconSpec(symbol: "archivebox.fill",       top: rgb(0xFAD478), bottom: rgb(0x9C6A12)),
        "badge-champion":     RewardIconSpec(symbol: "rosette",               top: rgb(0xD2A8F0), bottom: rgb(0x6A2D9C)),
        "grand-light":        RewardIconSpec(symbol: "burst.fill",            top: rgb(0xFFF1B8), bottom: rgb(0xE8A012)),
    ]

    static let fallback = RewardIconSpec(symbol: "star.fill", top: rgb(0xFFE08A), bottom: rgb(0xD99A1B))

    static func collectibleSpec(for id: String) -> RewardIconSpec {
        collectibles[id] ?? fallback
    }

    static func badgeSpec(for id: String) -> RewardIconSpec {
        badges[id] ?? fallback
    }

    /// Gold ring around earned treasures.
    static let goldRing: [Color] = [rgb(0xFFE9A8), rgb(0xC89018)]
}

// MARK: - Collectible icon (treasure gem)

struct CollectibleIconView: View {
    let collectible: Collectible
    var size: CGFloat = 56
    var earned: Bool = true

    private var spec: RewardIconSpec { RewardIconCatalog.collectibleSpec(for: collectible.id) }

    var body: some View {
        ZStack {
            // Gem disc — light catches the upper-left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [spec.top, spec.bottom],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: size * 0.05,
                        endRadius: size * 0.78
                    )
                )

            // Glassy top highlight
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.38), .white.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: size * 0.72, height: size * 0.38)
                .offset(y: -size * 0.25)

            // Ring — gold once earned, faint pewter until then
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: earned ? RewardIconCatalog.goldRing : [.white.opacity(0.3), .white.opacity(0.12)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: max(1.5, size * 0.05)
                )

            glyph

            if earned {
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.15, weight: .bold))
                    .foregroundStyle(.white.opacity(0.95))
                    .offset(x: size * 0.25, y: -size * 0.29)
            }
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .saturation(earned ? 1 : 0)
        .opacity(earned ? 1 : 0.45)
        .shadow(color: earned ? spec.bottom.opacity(0.55) : .clear, radius: size * 0.12)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var glyph: some View {
        if UIImage(systemName: spec.symbol) != nil {
            Image(systemName: spec.symbol)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [.white, .white.opacity(0.82)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: spec.bottom.opacity(0.7), radius: size * 0.035, y: size * 0.02)
                .frame(width: size * 0.62, height: size * 0.62)
                .minimumScaleFactor(0.5)
        } else {
            Text(collectible.emoji)
                .font(.system(size: size * 0.44))
        }
    }
}

// MARK: - Badge icon (medal)

struct BadgeIconView: View {
    let badgeID: String
    var size: CGFloat = 52
    var earned: Bool = true

    /// Original emoji fallback if a symbol is ever unavailable.
    private var emoji: String { ReadingStreak.badgeInfo[badgeID]?.icon ?? "🌟" }
    private var spec: RewardIconSpec { RewardIconCatalog.badgeSpec(for: badgeID) }

    var body: some View {
        ZStack {
            // Scalloped medal backplate
            Image(systemName: "seal.fill")
                .font(.system(size: size * 0.96))
                .foregroundStyle(
                    LinearGradient(
                        colors: [spec.top, spec.bottom],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            // Inner rim for depth
            Image(systemName: "seal")
                .font(.system(size: size * 0.78, weight: .thin))
                .foregroundStyle(.white.opacity(earned ? 0.45 : 0.25))

            glyph
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .saturation(earned ? 1 : 0)
        .opacity(earned ? 1 : 0.4)
        .shadow(color: earned ? spec.bottom.opacity(0.5) : .clear, radius: size * 0.11)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var glyph: some View {
        if UIImage(systemName: spec.symbol) != nil {
            Image(systemName: spec.symbol)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [.white, .white.opacity(0.85)], startPoint: .top, endPoint: .bottom)
                )
                .shadow(color: spec.bottom.opacity(0.7), radius: size * 0.03, y: size * 0.015)
                .frame(width: size * 0.46, height: size * 0.46)
                .minimumScaleFactor(0.5)
        } else {
            Text(emoji)
                .font(.system(size: size * 0.36))
        }
    }
}

// MARK: - Preview

#Preview("Collectibles") {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
            ForEach(Collectible.all) { c in
                VStack(spacing: 4) {
                    CollectibleIconView(collectible: c, size: 56)
                    Text(c.name).font(.system(size: 8))
                }
            }
        }
        .padding()
    }
    .background(Color(red: 0.07, green: 0.10, blue: 0.18))
}

#Preview("Badges") {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
            ForEach(ReadingStreak.badgeInfo.keys.sorted(), id: \.self) { id in
                VStack(spacing: 4) {
                    BadgeIconView(badgeID: id, size: 56)
                    Text(ReadingStreak.badgeInfo[id]?.name ?? "").font(.system(size: 8))
                }
            }
        }
        .padding()
    }
    .background(Color(red: 0.07, green: 0.10, blue: 0.18))
}
