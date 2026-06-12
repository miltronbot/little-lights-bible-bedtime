
import Foundation

@MainActor
final class StoryLibraryViewModel: ObservableObject {
    @Published private(set) var stories: [Story] = []
    @Published var selectedCategory: StoryCategory?
    @Published var selectedAgeGroup: AgeGroup?
    @Published var searchText: String = ""

    /// Set by Wind-Down auto mode when the app opens at/after bedtime: the
    /// story staged for a one-tap start on Home. Never auto-played.
    @Published var pendingTonightsStory: Story?

    private let repository = StoryRepository()

    init() {
        loadStories()
    }

    /// "Tonight's Story" — rotates daily based on day of year
    var tonightsStory: Story? {
        guard !stories.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % stories.count
        return stories[index]
    }

    var featuredStory: Story? { stories.first }

    var filteredStories: [Story] {
        stories.filter { story in
            let matchesCategory = selectedCategory == nil || story.category == selectedCategory
            let matchesAge = selectedAgeGroup == nil || story.ageGroup == selectedAgeGroup
            let matchesSearch = searchText.isEmpty
                || story.title.localizedCaseInsensitiveContains(searchText)
                || story.subtitle.localizedCaseInsensitiveContains(searchText)
                || story.bibleReference.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch && matchesAge
        }
    }

    /// Stories grouped by category for the home screen
    var storiesByCategory: [StoryCategory: [Story]] {
        Dictionary(grouping: stories, by: { $0.category })
    }

    /// Recently added or seasonal stories
    var recentStories: [Story] {
        Array(stories.suffix(5))
    }

    func loadStories() {
        do {
            stories = try repository.loadStories()
        } catch {
            #if DEBUG
            print("Failed to load stories: \(error)")
            #endif
            stories = []
        }
    }
}
