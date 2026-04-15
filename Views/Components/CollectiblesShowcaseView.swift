import SwiftUI

struct CollectiblesShowcaseView: View {
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var manager: CollectiblesManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Collectibles")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: settings.isBedtimeMode))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Collectible.all) { collectible in
                        CollectibleItemView(
                            collectible: collectible,
                            isCollected: manager.hasCollected(collectible.id)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }

            Text("\(manager.collectedCount) of \(Collectible.all.count) collected")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: settings.isBedtimeMode))
                .padding(.horizontal, 16)
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
