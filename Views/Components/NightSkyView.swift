import SwiftUI

// MARK: - Lumi's Night Sky
// A personal scene the child decorates with earned treasures: tap a
// collected treasure in the drawer to place it in the sky, drag it
// anywhere, long-press to put it back. Layouts persist per child.
// Creative play that gives the collection a home beyond the album.

struct NightSkyView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var manager: CollectiblesManager

    /// id → position as fractions of the canvas (device-size independent)
    @State private var placed: [String: CGPoint] = [:]
    @State private var loaded = false

    private var storageKey: String {
        ProfileScope.key("nightSky.positions", profile: appSettings.activeChildName)
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

                // Lumi keeps the child company while they decorate
                WanderingLumiView(storyID: "night-sky")

                if collected.isEmpty {
                    VStack(spacing: 12) {
                        Text("🌌")
                            .font(.system(size: 56))
                        Text("Finish stories to earn treasures,\nthen build your own night sky!")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }

                // Placed stickers — draggable, long-press returns to drawer
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
                                .onEnded { _ in save() }
                        )
                        .onLongPressGesture(minimumDuration: 0.7) {
                            withAnimation(.spring(response: 0.35)) {
                                placed[item.id] = nil
                            }
                            save()
                        }
                }

                // Treasure drawer
                VStack {
                    Spacer()
                    if !drawerItems.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Tap a treasure to place it · drag to move · hold to put back")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.65))
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
                                            save()
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
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.45))
                    }
                }
            }
        }
        .navigationTitle("Lumi's Night Sky")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if !loaded { load(); loaded = true } }
    }

    // MARK: Persistence (per child)

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let raw = try? JSONDecoder().decode([String: [Double]].self, from: data) else { return }
        placed = raw.compactMapValues { v in
            v.count == 2 ? CGPoint(x: v[0], y: v[1]) : nil
        }
    }

    private func save() {
        let raw = placed.mapValues { [Double($0.x), Double($0.y)] }
        if let data = try? JSONEncoder().encode(raw) {
            UserDefaults.standard.set(data, forKey: storageKey)
            CloudSync.mirror(data, forKey: storageKey)
        }
    }
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
