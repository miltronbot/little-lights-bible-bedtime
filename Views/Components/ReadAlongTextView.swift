import SwiftUI

// MARK: - ReadAlongTextView
struct ReadAlongTextView: View {
    let storyText: String
    var currentParagraphIndex: Int? = nil

    @EnvironmentObject var appSettings: AppSettings
    @State private var activeIndex: Int?

    private var paragraphs: [String] {
        storyText
            .split(separator: "\n\n", omittingEmptySubsequences: true)
            .map(String.init)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                ParagraphView(
                    text: paragraph,
                    isActive: activeIndex == index || currentParagraphIndex == index,
                    fontSize: appSettings.fontSize
                )
                .contentShape(Rectangle())
                .simultaneousGesture(
                    TapGesture().onEnded {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            activeIndex = activeIndex == index ? nil : index
                        }
                    }
                )
            }
        }
    }
}

// MARK: - ParagraphView
struct ParagraphView: View {
    let text: String
    let isActive: Bool
    let fontSize: Double

    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        Text(text)
            .font(.system(size: fontSize))
            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            .lineSpacing(appSettings.isBedtimeMode ? 8 : 6)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isActive
                            ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.12)
                            : Color.clear
                    )
            )
    }
}
