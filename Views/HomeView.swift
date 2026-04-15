
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: StoryLibraryViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel

    @State private var lumiGreeting: String? = nil

    private var lumiTimeMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 18 { return "Sleepy time!" }
        else if hour >= 12 { return "Story time!" }
        else { return "Good morning!" }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Header with greeting and Lumi
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(personalizedGreeting)
                            .font(.title2)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        Text("Little Lights")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        + Text(" Bible Bedtime")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    }
                    Spacer()
                    LumiMascotView(size: 32, message: lumiGreeting)
                }
                .onAppear { lumiGreeting = lumiTimeMessage }

                // MARK: - Reading Streak Banner
                StreakBannerView()

                // MARK: - Recently Read
                if !recentlyReadStories.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                            Text("Recently Read")
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recentlyReadStories.prefix(3)) { story in
                                    NavigationLink(destination: StoryDetailView(story: story)) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            StoryArtworkView(story: story, cornerRadius: 14)
                                                .frame(width: 140, height: 100)
                                            Text(story.title)
                                                .font(.caption.bold())
                                                .lineLimit(2)
                                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                        }
                                        .frame(width: 140)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 0)
                        }
                    }
                }

                // MARK: - Your Favorites
                if !favoritesViewModel.favoriteStoryIDs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.red)
                            Text("Your Favorites")
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            Spacer()
                            NavigationLink(destination: FavoritesView()) {
                                Text("See All")
                                    .font(.caption.bold())
                                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                            }
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(favoriteStories.prefix(3)) { story in
                                    NavigationLink(destination: StoryDetailView(story: story)) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            StoryArtworkView(story: story, cornerRadius: 14)
                                                .frame(width: 140, height: 100)
                                            Text(story.title)
                                                .font(.caption.bold())
                                                .lineLimit(2)
                                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                        }
                                        .frame(width: 140)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 0)
                        }
                    }
                }

                // MARK: - Tonight's Story
                if let tonightsStory = viewModel.tonightsStory {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                            Text("Tonight's Story")
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        }

                        NavigationLink(destination: StoryDetailView(story: tonightsStory)) {
                            TonightsStoryCard(story: tonightsStory)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // MARK: - Story of the Week
                if let weeklyStory = storyOfTheWeek {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("Story of the Week")
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        }

                        NavigationLink(destination: StoryDetailView(story: weeklyStory)) {
                            StoryOfTheWeekCard(story: weeklyStory)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // MARK: - Bedtime Routine Quick Start
                BedtimeRoutineCard()

                // MARK: - Browse by Category
                VStack(alignment: .leading, spacing: 12) {
                    Text("Browse by Theme")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 10) {
                        ForEach(StoryCategory.allCases) { category in
                            NavigationLink(destination: LibraryView(initialCategory: category)) {
                                CategoryCard(category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // MARK: - Seasonal Pick
                if let seasonalStory = seasonalPickStory {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: seasonalPickIcon)
                                .foregroundStyle(seasonalPickColor)
                            Text(seasonalPickTitle)
                                .font(.title3.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        }

                        NavigationLink(destination: StoryDetailView(story: seasonalStory)) {
                            SeasonalPickCard(story: seasonalStory, themeColor: seasonalPickColor)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // MARK: - Continue Listening
                if audioPlayer.currentStoryID != nil {
                    MiniPlayerBar()
                }

                // MARK: - All Stories
                VStack(alignment: .leading, spacing: 12) {
                    Text("All 50 Stories")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    ForEach(viewModel.stories.prefix(8)) { story in
                        NavigationLink(destination: StoryDetailView(story: story)) {
                            StoryCardView(story: story)
                        }
                        .buttonStyle(.plain)
                    }

                    NavigationLink(destination: LibraryView()) {
                        Text("See All Stories")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding()
        }
        .background {
            if appSettings.isBedtimeMode {
                StarryNightBackground()
            } else {
                AppTheme.background(for: false)
            }
        }
        .navigationTitle("Home")
    }

    private var recentlyReadStories: [Story] {
        let recentDates = readingStreak.streak.storiesReadDates.sorted(by: { $0.value > $1.value })
        let recentStoryIDs = recentDates.map { $0.key }
        return viewModel.stories.filter { recentStoryIDs.contains($0.id) }
            .sorted { story1, story2 in
                guard let index1 = recentStoryIDs.firstIndex(of: story1.id),
                      let index2 = recentStoryIDs.firstIndex(of: story2.id) else { return false }
                return index1 < index2
            }
    }

    private var favoriteStories: [Story] {
        viewModel.stories.filter { favoritesViewModel.favoriteStoryIDs.contains($0.id) }
    }

    private var storyOfTheWeek: Story? {
        guard !viewModel.stories.isEmpty else { return nil }
        let weekOfYear = Calendar.current.component(.weekOfYear, from: Date())
        // weekOfYear is 1-based (1–53); subtract 1 for a uniform 0-based rotation
        let storyIndex = (weekOfYear - 1) % viewModel.stories.count
        return viewModel.stories[storyIndex]
    }

    private var seasonalPickStory: Story? {
        let month = Calendar.current.component(.month, from: Date())
        let targetCategories: [StoryCategory]

        switch month {
        case 12: // December - Christmas/birth of Jesus
            targetCategories = [.hope, .love]
        case 3, 4: // March/April - Easter
            targetCategories = [.hope]
        default: // Other months - rotate through categories
            let monthRotation = month % 7
            if monthRotation == 0 {
                targetCategories = [.trust]
            } else if monthRotation == 1 {
                targetCategories = [.courage]
            } else if monthRotation == 2 {
                targetCategories = [.peace]
            } else if monthRotation == 3 {
                targetCategories = [.love]
            } else if monthRotation == 4 {
                targetCategories = [.prayer]
            } else if monthRotation == 5 {
                targetCategories = [.kindness]
            } else {
                targetCategories = [.hope]
            }
        }

        return viewModel.stories.first { targetCategories.contains($0.category) }
    }

    private var seasonalPickTitle: String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 12:
            return "Christmas Special"
        case 3, 4:
            return "Easter Special"
        default:
            return "Seasonal Pick"
        }
    }

    private var seasonalPickIcon: String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 12:
            return "snowflake"
        case 3, 4:
            return "leaf.fill"
        default:
            return "sparkles"
        }
    }

    private var seasonalPickColor: Color {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 12:
            return .blue
        case 3, 4:
            return .green
        default:
            return .purple
        }
    }

    private var personalizedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        if hour < 12 { timeGreeting = "Good Morning" }
        else if hour < 17 { timeGreeting = "Good Afternoon" }
        else { timeGreeting = "Good Evening" }

        let name = appSettings.activeChildName
        if !name.isEmpty {
            return "\(timeGreeting), \(name)"
        }
        return timeGreeting
    }
}

// MARK: - Tonight's Story Card

struct TonightsStoryCard: View {
    let story: Story
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            StoryArtworkView(story: story, cornerRadius: 24)
                .frame(height: 200)
                .overlay {
                    LinearGradient(colors: [.clear, Color.black.opacity(0.5)], startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "moon.fill")
                        .font(.caption)
                    Text("Selected for tonight")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.85))

                Text(story.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    Label(story.bibleReference, systemImage: "book.closed.fill")
                    Label("\(story.listenDurationMinutes) min", systemImage: "headphones")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
    }
}

// MARK: - Story of the Week Card

struct StoryOfTheWeekCard: View {
    let story: Story
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            StoryArtworkView(story: story, cornerRadius: 24)
                .frame(height: 200)
                .overlay {
                    LinearGradient(colors: [.clear, Color.black.opacity(0.4)], startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }

            // Golden badge pinned to top-trailing
            VStack {
                HStack {
                    Spacer()
                    Image(systemName: "star.circle.fill")
                        .font(.title)
                        .foregroundStyle(.yellow)
                        .padding(8)
                        .background(Circle().fill(Color.black.opacity(0.3)))
                        .padding()
                }
                Spacer()
            }

            // Story info at bottom-leading
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("This week's pick")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.85))

                Text(story.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    Label(story.bibleReference, systemImage: "book.closed.fill")
                    Label("\(story.listenDurationMinutes) min", systemImage: "headphones")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Seasonal Pick Card

struct SeasonalPickCard: View {
    let story: Story
    let themeColor: Color
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            StoryArtworkView(story: story, cornerRadius: 24)
                .frame(height: 180)
                .overlay {
                    LinearGradient(colors: [.clear, themeColor.opacity(0.4)], startPoint: .center, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(story.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                HStack(spacing: 12) {
                    Label(story.bibleReference, systemImage: "book.closed.fill")
                    Label("\(story.listenDurationMinutes) min", systemImage: "headphones")
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
        }
    }
}

// MARK: - Streak Banner

struct StreakBannerView: View {
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("\(readingStreak.currentStreak)")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("Streak")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            Divider().frame(height: 40)

            VStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundStyle(.yellow)
                Text("\(readingStreak.sleepStars)")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("Sleep Stars")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            Divider().frame(height: 40)

            VStack(spacing: 2) {
                Image(systemName: "book.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                Text("\(readingStreak.totalStoriesRead)")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("Stories")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            Spacer()

            if readingStreak.isActiveToday {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Bedtime Routine Card

struct BedtimeRoutineCard: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var viewModel: StoryLibraryViewModel

    var body: some View {
        NavigationLink(destination: BedtimeRoutineView()) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.indigo, Color.purple.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    Image(systemName: "bed.double.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Bedtime Routine")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Story + Prayer + Ambient Sounds")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
            .padding()
            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: StoryCategory
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(.white)
            Text(category.rawValue)
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .background(
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var gradientColors: [Color] {
        switch category {
        case .trust: return [.blue, .cyan]
        case .courage: return [.orange, .red]
        case .peace: return [.green, .mint]
        case .love: return [.pink, .red]
        case .hope: return [.yellow, .orange]
        case .prayer: return [.purple, .indigo]
        case .kindness: return [.teal, .green]
        }
    }
}

// MARK: - Mini Player Bar

struct MiniPlayerBar: View {
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "waveform")
                .font(.title3)
                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))

            VStack(alignment: .leading, spacing: 2) {
                Text("Now Playing")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                ProgressView(value: audioPlayer.progress)
                    .tint(AppTheme.accent(for: appSettings.isBedtimeMode))
            }

            Button {
                audioPlayer.isPlaying ? audioPlayer.pause() : audioPlayer.play()
            } label: {
                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
