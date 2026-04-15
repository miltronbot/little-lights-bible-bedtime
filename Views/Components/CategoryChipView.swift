
import SwiftUI

struct CategoryChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.accent(for: appSettings.isBedtimeMode) : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                .foregroundStyle(isSelected ? .white : AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
