import SwiftUI

struct CollectiblesShowcaseView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var manager: CollectiblesManager
    @State private var selectedCollectible: Collectible?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collectibles")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: settings.isBedtimeMode))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Collectible.all) { collectible in
                        Button {
                            selectedCollectible = collectible
                        } label: {
                            CollectibleItemView(
                                collectible: collectible,
                                isCollected: manager.hasCollected(collectible.id)
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Shows how to collect this treasure")
                    }
                }
                .padding(.horizontal, 16)
            }

            Text("\(manager.collectedCount) of \(Collectible.all.count) collected · tap any treasure to learn how to earn it")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: settings.isBedtimeMode))
                .padding(.horizontal, 16)
        }
        .sheet(item: $selectedCollectible) { collectible in
            CollectibleDetailSheet(
                collectible: collectible,
                isCollected: manager.hasCollected(collectible.id)
            )
        }
    }
}

struct CollectibleItemView: View {
    let collectible: Collectible
    let isCollected: Bool
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        VStack(spacing: 8) {
            Text(collectible.emoji)
                .font(.system(size: 40))
                .opacity(isCollected ? 1.0 : 0.3)

            Text(collectible.name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.primaryText(for: settings.isBedtimeMode))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .opacity(isCollected ? 1.0 : 0.3)
        }
        .frame(width: 80)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardBackground(for: settings.isBedtimeMode))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isCollected ? AppTheme.accent(for: settings.isBedtimeMode) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}
