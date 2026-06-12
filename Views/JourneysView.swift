
import SwiftUI

// MARK: - 7-Day Journeys
// Browse list of themed week-long story plans. Each card opens a
// JourneyDetailView with the seven daily stories and completion marks.

struct JourneysView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var journeyProgress: JourneyProgressManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Intro
                HStack(spacing: 10) {
                    LumiMascotView(size: 32, message: nil)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("7-Day Journeys")
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Text("A gentle week of stories on one theme")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }
                    Spacer()
                }
                .padding(.top, 4)

                ForEach(Journey.all) { journey in
                    NavigationLink(destination: JourneyDetailView(journey: journey)) {
                        JourneyCard(journey: journey)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(AppTheme.background(for: appSettings.isBedtimeMode).ignoresSafeArea())
        .navigationTitle("Journeys")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Journey Card

private struct JourneyCard: View {
    let journey: Journey

    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var journeyProgress: JourneyProgressManager

    private var completedCount: Int {
        journeyProgress.completedDays(forJourney: journey.id).count
    }

    private var isComplete: Bool {
        journeyProgress.isComplete(journey)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: journey.iconSystemName)
                        .font(.system(size: 22))
                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(journey.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text(journey.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                if isComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                }
            }

            // Progress dots — one per day
            HStack(spacing: 6) {
                ForEach(1...journey.storyIDs.count, id: \.self) { day in
                    let done = journeyProgress.completedDays(forJourney: journey.id).contains(day)
                    Circle()
                        .fill(done
                              ? AppTheme.accent(for: appSettings.isBedtimeMode)
                              : AppTheme.secondaryText(for: appSettings.isBedtimeMode).opacity(0.25))
                        .frame(width: 10, height: 10)
                }
                Spacer()
                Text("\(completedCount)/\(journey.storyIDs.count)")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
