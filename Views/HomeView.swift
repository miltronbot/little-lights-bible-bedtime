
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: StoryLibraryViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel

    @State private var lumiGreeting: String? = nil
    @State private var showSideMenu = false
    @State private var menuDestination: SideMenuDestination?

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
                        // With multiple children, tapping the greeting switches profiles
                        if appSettings.childrenNames.count > 1 {
                            Menu {
                                ForEach(Array(appSettings.childrenNames.enumerated()), id: \.offset) { index, name in
                                    Button {
                                        appSettings.switchToChild(at: index)
                                    } label: {
                                        if index == appSettings.activeChildIndex {
                                            Label(name, systemImage: "checkmark")
                                        } else {
                                            Text(name)
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Text(personalizedGreeting)
                                        .font(.title2)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                }
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            }
                        } else {
                            Text(personalizedGreeting)
                                .font(.title2)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        }
                        Text("Bible Bedtime")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        + Text(" Stories")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    }
                    Spacer()
                    LumiMascotView(size: 32, message: lumiGreeting)
                }
                .onAppear { lumiGreeting = lumiTimeMessage }

                // MARK: - Reading Streak Banner
                StreakBannerView()

                // MARK: - Verse of the Day
                VerseOfTheDayCard()

                // MARK: - Tonight's Goals
                TonightsGoalsCard()

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

                // Browse by Theme now lives in the slide-out side menu
                // (hamburger button, top left) — see SideMenuView

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
                        StoryCardView(story: story)
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
            // Always a starry night sky — full effect in bedtime mode,
            // a calmer dimmed version otherwise
            StarryNightBackground(alwaysStarry: true)
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        showSideMenu = true
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                }
                .accessibilityLabel("Open menu")
            }
        }
        .overlay {
            SideMenuView(isOpen: $showSideMenu, selection: $menuDestination)
        }
        .navigationDestination(item: $menuDestination) { destination in
            switch destination {
            case .theme(let category):
                LibraryView(initialCategory: category)
            case .bedtimeRoutine:
                BedtimeRoutineView()
            case .parentDashboard:
                ParentDashboardView()
            case .nightSky:
                NightSkyView()
            case .journeys:
                JourneysView()
            }
        }
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
                    // Moonlit glow behind the icon, like the theme cards
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.purple.opacity(0.65), Color.indigo.opacity(0.30), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 34
                            )
                        )
                        .frame(width: 68, height: 68)
                        .blur(radius: 4)
                    Image(systemName: "bed.double.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .shadow(color: .purple.opacity(0.8), radius: 8)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Bedtime Routine")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
                    Text("Story + Prayer + Ambient Sounds")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .background(
                ZStack {
                    // Twilight sky gradient, same palette family as the painted story scenes
                    LinearGradient(
                        stops: [
                            .init(color: skyTop, location: 0.0),
                            .init(color: skyMid, location: 0.55),
                            .init(color: skyHorizon, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Tiny sparkle accents
                    GeometryReader { geo in
                        Image(systemName: "sparkle")
                            .font(.system(size: 7))
                            .foregroundStyle(.white.opacity(0.55))
                            .position(x: geo.size.width * 0.30, y: geo.size.height * 0.25)
                        Image(systemName: "sparkle")
                            .font(.system(size: 5))
                            .foregroundStyle(.white.opacity(0.35))
                            .position(x: geo.size.width * 0.60, y: geo.size.height * 0.70)
                        Image(systemName: "sparkle")
                            .font(.system(size: 6))
                            .foregroundStyle(.white.opacity(0.45))
                            .position(x: geo.size.width * 0.82, y: geo.size.height * 0.30)
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.30))
                            .position(x: geo.size.width * 0.93, y: geo.size.height * 0.22)
                    }
                }
                .allowsHitTesting(false)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    // Deep night-sky tones — bedtime mode dims them further, matching the theme cards
    private var skyTop: Color {
        appSettings.isBedtimeMode ? Color(red: 0.13, green: 0.11, blue: 0.30) : Color(red: 0.19, green: 0.16, blue: 0.42)
    }

    private var skyMid: Color {
        appSettings.isBedtimeMode ? Color(red: 0.18, green: 0.14, blue: 0.38) : Color(red: 0.26, green: 0.21, blue: 0.52)
    }

    private var skyHorizon: Color {
        appSettings.isBedtimeMode ? Color(red: 0.24, green: 0.16, blue: 0.40) : Color(red: 0.34, green: 0.24, blue: 0.55)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: StoryCategory
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ZStack {
            // Twilight sky gradient, same palette family as the painted story scenes
            LinearGradient(
                stops: [
                    .init(color: skyTop, location: 0.0),
                    .init(color: skyMid, location: 0.55),
                    .init(color: skyHorizon, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Soft celestial glow behind the icon
            Circle()
                .fill(
                    RadialGradient(
                        colors: [glowColor.opacity(0.55), glowColor.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 38
                    )
                )
                .frame(width: 76, height: 76)
                .offset(y: -10)
                .blur(radius: 6)
                .allowsHitTesting(false)

            // Tiny sparkle accents
            Image(systemName: "sparkle")
                .font(.system(size: 7))
                .foregroundStyle(.white.opacity(0.55))
                .offset(x: -52, y: -24)
                .allowsHitTesting(false)
            Image(systemName: "sparkle")
                .font(.system(size: 5))
                .foregroundStyle(.white.opacity(0.35))
                .offset(x: 56, y: -10)
                .allowsHitTesting(false)
            Image(systemName: "sparkle")
                .font(.system(size: 6))
                .foregroundStyle(.white.opacity(0.45))
                .offset(x: 40, y: -30)
                .allowsHitTesting(false)

            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .shadow(color: glowColor.opacity(0.8), radius: 8)
                Text(category.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 16))
    }

    // Muted twilight tones per category — bedtime mode dims them further,
    // mirroring StoryArtwork's paired palettes
    private var skyTop: Color {
        let dim = appSettings.isBedtimeMode
        switch category {
        case .trust:    return dim ? Color(red: 0.10, green: 0.16, blue: 0.34) : Color(red: 0.16, green: 0.26, blue: 0.50)
        case .courage:  return dim ? Color(red: 0.30, green: 0.17, blue: 0.10) : Color(red: 0.44, green: 0.26, blue: 0.14)
        case .peace:    return dim ? Color(red: 0.08, green: 0.22, blue: 0.20) : Color(red: 0.12, green: 0.32, blue: 0.29)
        case .love:     return dim ? Color(red: 0.32, green: 0.13, blue: 0.20) : Color(red: 0.46, green: 0.20, blue: 0.30)
        case .hope:     return dim ? Color(red: 0.32, green: 0.24, blue: 0.10) : Color(red: 0.46, green: 0.34, blue: 0.13)
        case .prayer:   return dim ? Color(red: 0.22, green: 0.14, blue: 0.36) : Color(red: 0.32, green: 0.20, blue: 0.50)
        case .kindness: return dim ? Color(red: 0.10, green: 0.24, blue: 0.14) : Color(red: 0.15, green: 0.34, blue: 0.20)
        }
    }

    private var skyMid: Color {
        let dim = appSettings.isBedtimeMode
        switch category {
        case .trust:    return dim ? Color(red: 0.14, green: 0.20, blue: 0.42) : Color(red: 0.22, green: 0.33, blue: 0.60)
        case .courage:  return dim ? Color(red: 0.36, green: 0.22, blue: 0.12) : Color(red: 0.55, green: 0.34, blue: 0.17)
        case .peace:    return dim ? Color(red: 0.11, green: 0.28, blue: 0.26) : Color(red: 0.17, green: 0.41, blue: 0.37)
        case .love:     return dim ? Color(red: 0.38, green: 0.17, blue: 0.26) : Color(red: 0.56, green: 0.27, blue: 0.38)
        case .hope:     return dim ? Color(red: 0.38, green: 0.29, blue: 0.13) : Color(red: 0.57, green: 0.43, blue: 0.18)
        case .prayer:   return dim ? Color(red: 0.27, green: 0.18, blue: 0.44) : Color(red: 0.40, green: 0.27, blue: 0.61)
        case .kindness: return dim ? Color(red: 0.13, green: 0.30, blue: 0.18) : Color(red: 0.20, green: 0.43, blue: 0.26)
        }
    }

    private var skyHorizon: Color {
        let dim = appSettings.isBedtimeMode
        switch category {
        case .trust:    return dim ? Color(red: 0.20, green: 0.18, blue: 0.40) : Color(red: 0.32, green: 0.30, blue: 0.62)
        case .courage:  return dim ? Color(red: 0.42, green: 0.28, blue: 0.14) : Color(red: 0.65, green: 0.44, blue: 0.22)
        case .peace:    return dim ? Color(red: 0.15, green: 0.24, blue: 0.34) : Color(red: 0.23, green: 0.37, blue: 0.50)
        case .love:     return dim ? Color(red: 0.42, green: 0.24, blue: 0.22) : Color(red: 0.62, green: 0.36, blue: 0.33)
        case .hope:     return dim ? Color(red: 0.43, green: 0.31, blue: 0.18) : Color(red: 0.66, green: 0.49, blue: 0.27)
        case .prayer:   return dim ? Color(red: 0.18, green: 0.17, blue: 0.38) : Color(red: 0.28, green: 0.26, blue: 0.55)
        case .kindness: return dim ? Color(red: 0.15, green: 0.30, blue: 0.26) : Color(red: 0.23, green: 0.43, blue: 0.37)
        }
    }

    // Same glow mapping the story artwork uses for its atmospheric effects
    private var glowColor: Color {
        switch category {
        case .peace:    return .cyan
        case .love:     return .pink
        case .hope:     return .yellow
        case .courage:  return .orange
        case .trust:    return .blue
        case .prayer:   return .purple
        case .kindness: return .green
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
