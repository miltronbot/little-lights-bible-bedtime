
import SwiftUI

struct PremiumTeaserCard: View {
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [.purple.opacity(0.85), .indigo.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 72, height: 72)
                .overlay {
                    Image(systemName: "lock.open.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text("Unlock the Full Library")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("Get all 50 calming Bible bedtime stories.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                Text("One-time purchase")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            Spacer()
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
