
import Foundation

struct Story: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let bibleReference: String
    let category: StoryCategory
    let isFree: Bool
    let readDurationMinutes: Int
    let listenDurationMinutes: Int
    let imageName: String
    let audioFileName: String
    let storyText: String
    let takeaway: String
    let bedtimePrayer: String

    // New fields with defaults for backward compatibility
    var memoryVerse: String?
    var ageGroup: AgeGroup?

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, bibleReference, category, isFree
        case readDurationMinutes, listenDurationMinutes
        case imageName, audioFileName, storyText, takeaway, bedtimePrayer
        case memoryVerse, ageGroup
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        bibleReference = try container.decode(String.self, forKey: .bibleReference)
        category = try container.decode(StoryCategory.self, forKey: .category)
        isFree = try container.decode(Bool.self, forKey: .isFree)
        readDurationMinutes = try container.decode(Int.self, forKey: .readDurationMinutes)
        listenDurationMinutes = try container.decode(Int.self, forKey: .listenDurationMinutes)
        imageName = try container.decode(String.self, forKey: .imageName)
        audioFileName = try container.decode(String.self, forKey: .audioFileName)
        storyText = try container.decode(String.self, forKey: .storyText)
        takeaway = try container.decode(String.self, forKey: .takeaway)
        bedtimePrayer = try container.decode(String.self, forKey: .bedtimePrayer)
        memoryVerse = try container.decodeIfPresent(String.self, forKey: .memoryVerse)
        ageGroup = try container.decodeIfPresent(AgeGroup.self, forKey: .ageGroup)
    }
}

enum StoryCategory: String, Codable, CaseIterable, Identifiable {
    case trust = "Trust"
    case courage = "Courage"
    case peace = "Peace"
    case love = "Love"
    case hope = "Hope"
    case prayer = "Prayer"
    case kindness = "Kindness"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .trust: return "hand.raised.fill"
        case .courage: return "shield.fill"
        case .peace: return "leaf.fill"
        case .love: return "heart.fill"
        case .hope: return "sun.max.fill"
        case .prayer: return "hands.sparkles.fill"
        case .kindness: return "face.smiling.fill"
        }
    }
}

enum AgeGroup: String, Codable, CaseIterable, Identifiable {
    case toddler = "Ages 3-5"
    case child = "Ages 6-8"
    case preteen = "Ages 9-12"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .toddler: return "figure.child"
        case .child: return "figure.child.and.lock.fill"
        case .preteen: return "book.fill"
        }
    }

    var shortLabel: String {
        switch self {
        case .toddler: return "3-5"
        case .child: return "6-8"
        case .preteen: return "9-12"
        }
    }
}
