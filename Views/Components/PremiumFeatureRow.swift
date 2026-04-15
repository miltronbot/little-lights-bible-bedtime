
import SwiftUI

struct PremiumFeatureRow: View {
    let text: String

    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
            Text(text)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
        }
    }
}
