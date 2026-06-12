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

    /// Estimates which paragraph the narrator is reading right now by mapping
    /// playback progress onto each paragraph's share of the total character
    /// count (narration pace is roughly constant). Paragraph-level is the
    /// right granularity — we have no word timings for the bundled MP3s.
    /// Returns nil before playback has really begun.
    static func paragraphIndex(storyText: String,
                               currentTime: TimeInterval,
                               duration: TimeInterval) -> Int? {
        guard duration > 1, currentTime > 0 else { return nil }
        let paragraphs = storyText.split(separator: "\n\n", omittingEmptySubsequences: true)
        let total = paragraphs.reduce(0) { $0 + $1.count }
        guard total > 0 else { return nil }

        let progress = min(max(currentTime / duration, 0), 1)
        let target = progress * Double(total)
        var cumulative = 0.0
        for (index, paragraph) in paragraphs.enumerated() {
            cumulative += Double(paragraph.count)
            if target < cumulative { return index }
        }
        return paragraphs.count - 1
    }

    /// Anchor id for a paragraph — lets a parent ScrollViewReader follow the
    /// narration (see StoryStepView in BedtimeRoutineView).
    static func anchorID(for index: Int) -> String { "readalong-\(index)" }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                ParagraphView(
                    text: paragraph,
                    isActive: activeIndex == index || currentParagraphIndex == index,
                    fontSize: appSettings.fontSize
                )
                .id(Self.anchorID(for: index))
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
                            ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.15)
                            : Color.clear
                    )
            )
            .overlay(alignment: .leading) {
                // A soft reading-position marker so the current paragraph is
                // easy to find at a glance
                if isActive {
                    Capsule()
                        .fill(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.9))
                        .frame(width: 3)
                        .padding(.vertical, 10)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: isActive)
    }
}
