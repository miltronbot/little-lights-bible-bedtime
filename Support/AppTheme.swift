
import SwiftUI

enum AppTheme {
    static func background(for bedtimeMode: Bool) -> Color {
        bedtimeMode ? Color(red: 0.08, green: 0.09, blue: 0.16) : Color(.systemGroupedBackground)
    }

    static func cardBackground(for bedtimeMode: Bool) -> Color {
        bedtimeMode ? Color(red: 0.14, green: 0.15, blue: 0.24) : Color(.secondarySystemBackground)
    }

    static func accent(for bedtimeMode: Bool) -> Color {
        bedtimeMode ? Color(red: 0.47, green: 0.52, blue: 0.95) : .indigo
    }

    static func secondaryAccent(for bedtimeMode: Bool) -> Color {
        bedtimeMode ? Color(red: 0.35, green: 0.40, blue: 0.78) : .blue
    }

    static func primaryText(for bedtimeMode: Bool) -> Color {
        bedtimeMode ? .white : .primary
    }

    static func secondaryText(for bedtimeMode: Bool) -> Color {
        bedtimeMode ? Color.white.opacity(0.75) : .secondary
    }

    static func storyFont(for bedtimeMode: Bool) -> Font {
        bedtimeMode ? .system(size: 19) : .body
    }
}
