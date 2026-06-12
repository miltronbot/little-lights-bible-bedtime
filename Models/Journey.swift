import Foundation

// MARK: - 7-Day Journeys
// Themed bedtime plans that gather seven existing stories into a gentle
// week-long sequence. Each child keeps their own per-day progress (see
// JourneyProgressManager), so a journey can be walked once per child.
// Every storyID below MUST match an `id` in Resources/stories.json.

struct Journey: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let category: StoryCategory
    let iconSystemName: String
    let storyIDs: [String]   // exactly 7 — one per day

    // 4 starter journeys. Story IDs are real records from stories.json.
    static let all: [Journey] = [
        Journey(
            id: "brave-hearts",
            title: "Brave Hearts",
            subtitle: "Seven nights of courage with God",
            category: .courage,
            iconSystemName: "shield.fill",
            storyIDs: [
                "daniel-and-the-lions",
                "david-and-goliath",
                "esthers-courage",
                "moses-and-the-burning-bush",
                "gideons-brave-300",
                "shadrach-meshach-abednego",
                "peter-walks-on-water",
            ]
        ),
        Journey(
            id: "quiet-and-calm",
            title: "Quiet & Calm",
            subtitle: "Seven peaceful stories to drift to sleep",
            category: .peace,
            iconSystemName: "leaf.fill",
            storyIDs: [
                "jesus-calms-the-storm",
                "christmas-the-birth-of-jesus",
                "elijah-and-the-whisper",
                "david-shepherd-boy",
                "mary-and-martha",
                "the-light-of-the-world",
                "the-garden-of-eden",
            ]
        ),
        Journey(
            id: "always-loved",
            title: "Always Loved",
            subtitle: "Seven stories of God's gentle love",
            category: .love,
            iconSystemName: "heart.fill",
            storyIDs: [
                "the-lost-sheep",
                "zacchaeus",
                "jesus-loves-the-children",
                "the-prodigal-son",
                "jesus-heals-the-blind-man",
                "jesus-and-the-woman-at-the-well",
                "the-good-samaritan",
            ]
        ),
        Journey(
            id: "big-trust",
            title: "Big Trust",
            subtitle: "Seven nights of trusting a faithful God",
            category: .trust,
            iconSystemName: "hand.raised.fill",
            storyIDs: [
                "noah-big-boat",
                "jonah-and-the-big-fish",
                "feeding-the-five-thousand",
                "joshua-and-jericho",
                "abraham-and-the-stars",
                "the-walls-of-water",
                "jesus-walks-on-water",
            ]
        ),
    ]
}
