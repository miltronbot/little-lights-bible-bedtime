
import SwiftUI

// MARK: - Journey Detail
// A vertical seven-day plan. Each row resolves its storyID to a Story
// and links to StoryDetailView. The completion checkmark is a control
// OUTSIDE the NavigationLink (never nest a Button inside a NavigationLink
// label — gesture deadlock; see CLAUDE.md).

struct JourneyDetailView: View {
    let journey: Journey

    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var library: StoryLibraryViewModel
    @EnvironmentObject private var journeyProgress: JourneyProgressManager

    private func story(for id: String) -> Story? {
        library.stories.first { $0.id == id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                ForEach(Array(journey.storyIDs.enumerated()), id: \.offset) { index, storyID in
                    let day = index + 1
                    dayRow(day: day, storyID: storyID)
                }

                if journeyProgress.isComplete(journey) {
                    completionBanner
                }
            }
            .padding()
        }
        .background(AppTheme.background(for: appSettings.isBedtimeMode).ignoresSafeArea())
        .navigationTitle(journey.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.18))
                        .frame(width: 56, height: 56)
                    Image(systemName: journey.iconSystemName)
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(journey.title)
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text(journey.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            let done = journeyProgress.completedDays(forJourney: journey.id).count
            Text("\(done) of \(journey.storyIDs.count) nights complete")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: Day Row

    @ViewBuilder
    private func dayRow(day: Int, storyID: String) -> some View {
        let isDone = journeyProgress.completedDays(forJourney: journey.id).contains(day)

        HStack(spacing: 12) {
            // Day badge
            ZStack {
                Circle()
                    .fill(isDone
                          ? AppTheme.accent(for: appSettings.isBedtimeMode)
                          : AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.16))
                    .frame(width: 40, height: 40)
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(day)")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                }
            }

            // Story link — fills the rest of the row
            if let story = story(for: storyID) {
                NavigationLink(destination: StoryDetailView(story: story)) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Night \(day)")
                            .font(.caption2.bold())
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        Text(story.title)
                            .font(.subheadline.bold())
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .multilineTextAlignment(.leading)
                        Text(story.subtitle)
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                // Defensive: story missing from library
                VStack(alignment: .leading, spacing: 2) {
                    Text("Night \(day)")
                        .font(.caption2.bold())
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    Text("Story coming soon")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Mark-complete toggle — OUTSIDE the NavigationLink
            Button {
                if !isDone {
                    journeyProgress.markDayComplete(journeyID: journey.id, day: day)
                }
            } label: {
                Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isDone
                                     ? .yellow
                                     : AppTheme.secondaryText(for: appSettings.isBedtimeMode).opacity(0.6))
            }
            .buttonStyle(.plain)
            .disabled(isDone)
            .accessibilityLabel(isDone ? "Night \(day) complete" : "Mark night \(day) complete")
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Completion

    private var completionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title)
                .foregroundStyle(.yellow)
            VStack(alignment: .leading, spacing: 2) {
                Text("Journey complete!")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("You finished all seven nights. Wonderful!")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
