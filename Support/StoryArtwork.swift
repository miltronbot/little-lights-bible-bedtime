
import SwiftUI

struct StoryArtworkStyle {
    let primary: Color
    let secondary: Color
    let symbolName: String
    let accentSymbolName: String?
}

enum StoryArtwork {
    static func style(for storyID: String, bedtimeMode: Bool) -> StoryArtworkStyle {
        switch storyID {
        case "noah-big-boat":
            return .init(primary: bedtimeMode ? Color(red: 0.16, green: 0.27, blue: 0.48) : Color(red: 0.35, green: 0.55, blue: 0.82),
                         secondary: bedtimeMode ? Color(red: 0.36, green: 0.28, blue: 0.52) : Color(red: 0.64, green: 0.54, blue: 0.87),
                         symbolName: "ferry.fill", accentSymbolName: "cloud.rain.fill")
        case "daniel-and-the-lions":
            return .init(primary: bedtimeMode ? Color(red: 0.38, green: 0.24, blue: 0.14) : Color(red: 0.73, green: 0.50, blue: 0.24),
                         secondary: bedtimeMode ? Color(red: 0.25, green: 0.18, blue: 0.10) : Color(red: 0.91, green: 0.76, blue: 0.47),
                         symbolName: "pawprint.fill", accentSymbolName: "sparkles")
        case "david-and-goliath":
            return .init(primary: bedtimeMode ? Color(red: 0.22, green: 0.34, blue: 0.22) : Color(red: 0.46, green: 0.67, blue: 0.44),
                         secondary: bedtimeMode ? Color(red: 0.41, green: 0.29, blue: 0.18) : Color(red: 0.81, green: 0.63, blue: 0.43),
                         symbolName: "shield.fill", accentSymbolName: "circle.fill")
        case "jonah-and-the-big-fish":
            return .init(primary: bedtimeMode ? Color(red: 0.10, green: 0.31, blue: 0.44) : Color(red: 0.27, green: 0.67, blue: 0.84),
                         secondary: bedtimeMode ? Color(red: 0.16, green: 0.20, blue: 0.44) : Color(red: 0.48, green: 0.53, blue: 0.91),
                         symbolName: "fish.fill", accentSymbolName: "wind")
        case "baby-moses", "feeding-the-five-thousand":
            return .init(primary: bedtimeMode ? Color(red: 0.31, green: 0.23, blue: 0.14) : Color(red: 0.77, green: 0.61, blue: 0.40),
                         secondary: bedtimeMode ? Color(red: 0.11, green: 0.29, blue: 0.25) : Color(red: 0.47, green: 0.76, blue: 0.69),
                         symbolName: "basket.fill", accentSymbolName: storyID == "feeding-the-five-thousand" ? "fish.fill" : "water.waves")
        case "the-good-samaritan":
            return .init(primary: bedtimeMode ? Color(red: 0.42, green: 0.19, blue: 0.19) : Color(red: 0.85, green: 0.46, blue: 0.46),
                         secondary: bedtimeMode ? Color(red: 0.45, green: 0.31, blue: 0.14) : Color(red: 0.92, green: 0.72, blue: 0.40),
                         symbolName: "cross.case.fill", accentSymbolName: "heart.fill")
        case "jesus-calms-the-storm":
            return .init(primary: bedtimeMode ? Color(red: 0.12, green: 0.22, blue: 0.42) : Color(red: 0.36, green: 0.58, blue: 0.90),
                         secondary: bedtimeMode ? Color(red: 0.26, green: 0.18, blue: 0.42) : Color(red: 0.62, green: 0.54, blue: 0.90),
                         symbolName: "water.waves", accentSymbolName: "wind")
        case "the-lost-sheep":
            return .init(primary: bedtimeMode ? Color(red: 0.25, green: 0.29, blue: 0.31) : Color(red: 0.79, green: 0.83, blue: 0.87),
                         secondary: bedtimeMode ? Color(red: 0.35, green: 0.28, blue: 0.18) : Color(red: 0.90, green: 0.78, blue: 0.51),
                         symbolName: "leaf.fill", accentSymbolName: "heart.fill")
        case "creation-story":
            return .init(primary: bedtimeMode ? Color(red: 0.13, green: 0.19, blue: 0.38) : Color(red: 0.30, green: 0.45, blue: 0.88),
                         secondary: bedtimeMode ? Color(red: 0.38, green: 0.24, blue: 0.48) : Color(red: 0.85, green: 0.58, blue: 0.91),
                         symbolName: "sparkles", accentSymbolName: "sun.max.fill")
        case "joseph-and-his-colorful-coat":
            return .init(primary: bedtimeMode ? Color(red: 0.33, green: 0.20, blue: 0.46) : Color(red: 0.73, green: 0.49, blue: 0.89),
                         secondary: bedtimeMode ? Color(red: 0.15, green: 0.36, blue: 0.34) : Color(red: 0.37, green: 0.74, blue: 0.67),
                         symbolName: "tshirt.fill", accentSymbolName: "sparkles")
        case "the-wise-men":
            return .init(primary: bedtimeMode ? Color(red: 0.18, green: 0.18, blue: 0.42) : Color(red: 0.44, green: 0.46, blue: 0.90),
                         secondary: bedtimeMode ? Color(red: 0.45, green: 0.31, blue: 0.14) : Color(red: 0.95, green: 0.78, blue: 0.36),
                         symbolName: "star.fill", accentSymbolName: "gift.fill")
        case "the-birth-of-jesus", "christmas-the-birth-of-jesus":
            return .init(primary: bedtimeMode ? Color(red: 0.20, green: 0.22, blue: 0.44) : Color(red: 0.45, green: 0.52, blue: 0.94),
                         secondary: bedtimeMode ? Color(red: 0.44, green: 0.30, blue: 0.14) : Color(red: 0.96, green: 0.79, blue: 0.42),
                         symbolName: "star.leadinghalf.filled", accentSymbolName: "moon.stars.fill")
        case "zacchaeus":
            return .init(primary: bedtimeMode ? Color(red: 0.17, green: 0.33, blue: 0.21) : Color(red: 0.43, green: 0.69, blue: 0.45),
                         secondary: bedtimeMode ? Color(red: 0.31, green: 0.24, blue: 0.14) : Color(red: 0.73, green: 0.60, blue: 0.38),
                         symbolName: "tree.fill", accentSymbolName: "figure.walk")
        case "jesus-loves-the-children":
            return .init(primary: bedtimeMode ? Color(red: 0.33, green: 0.19, blue: 0.41) : Color(red: 0.76, green: 0.48, blue: 0.85),
                         secondary: bedtimeMode ? Color(red: 0.16, green: 0.30, blue: 0.28) : Color(red: 0.50, green: 0.78, blue: 0.73),
                         symbolName: "heart.fill", accentSymbolName: "figure.2.and.child.holdinghands")
        case "the-prodigal-son":
            return .init(primary: bedtimeMode ? Color(red: 0.37, green: 0.20, blue: 0.18) : Color(red: 0.86, green: 0.50, blue: 0.47),
                         secondary: bedtimeMode ? Color(red: 0.43, green: 0.30, blue: 0.18) : Color(red: 0.93, green: 0.73, blue: 0.43),
                         symbolName: "house.fill", accentSymbolName: "heart.fill")
        case "esthers-courage":
            return .init(primary: bedtimeMode ? Color(red: 0.34, green: 0.20, blue: 0.42) : Color(red: 0.73, green: 0.46, blue: 0.88),
                         secondary: bedtimeMode ? Color(red: 0.46, green: 0.31, blue: 0.13) : Color(red: 0.95, green: 0.74, blue: 0.35),
                         symbolName: "crown.fill", accentSymbolName: "sparkles")
        case "joshua-and-jericho":
            return .init(primary: bedtimeMode ? Color(red: 0.37, green: 0.24, blue: 0.14) : Color(red: 0.78, green: 0.55, blue: 0.33),
                         secondary: bedtimeMode ? Color(red: 0.18, green: 0.19, blue: 0.37) : Color(red: 0.43, green: 0.51, blue: 0.87),
                         symbolName: "building.columns.fill", accentSymbolName: "shield.fill")
        case "elijah-and-the-whisper":
            return .init(primary: bedtimeMode ? Color(red: 0.15, green: 0.28, blue: 0.34) : Color(red: 0.43, green: 0.73, blue: 0.79),
                         secondary: bedtimeMode ? Color(red: 0.32, green: 0.24, blue: 0.42) : Color(red: 0.73, green: 0.62, blue: 0.91),
                         symbolName: "wind", accentSymbolName: "sparkles")
        case "the-boy-samuel":
            return .init(primary: bedtimeMode ? Color(red: 0.18, green: 0.24, blue: 0.44) : Color(red: 0.46, green: 0.57, blue: 0.91),
                         secondary: bedtimeMode ? Color(red: 0.42, green: 0.29, blue: 0.14) : Color(red: 0.92, green: 0.76, blue: 0.39),
                         symbolName: "ear.fill", accentSymbolName: "moon.stars.fill")

        // New OT stories
        case "abraham-and-the-stars":
            return .init(primary: bedtimeMode ? Color(red: 0.10, green: 0.12, blue: 0.32) : Color(red: 0.20, green: 0.25, blue: 0.65),
                         secondary: bedtimeMode ? Color(red: 0.30, green: 0.22, blue: 0.45) : Color(red: 0.60, green: 0.50, blue: 0.88),
                         symbolName: "star.fill", accentSymbolName: "moon.stars.fill")
        case "ruth-and-naomi":
            return .init(primary: bedtimeMode ? Color(red: 0.35, green: 0.22, blue: 0.15) : Color(red: 0.78, green: 0.58, blue: 0.38),
                         secondary: bedtimeMode ? Color(red: 0.20, green: 0.32, blue: 0.20) : Color(red: 0.52, green: 0.72, blue: 0.48),
                         symbolName: "leaf.fill", accentSymbolName: "heart.fill")
        case "moses-and-the-burning-bush":
            return .init(primary: bedtimeMode ? Color(red: 0.40, green: 0.18, blue: 0.10) : Color(red: 0.88, green: 0.45, blue: 0.22),
                         secondary: bedtimeMode ? Color(red: 0.42, green: 0.30, blue: 0.12) : Color(red: 0.95, green: 0.72, blue: 0.28),
                         symbolName: "flame.fill", accentSymbolName: "sparkles")
        case "the-walls-of-water":
            return .init(primary: bedtimeMode ? Color(red: 0.08, green: 0.25, blue: 0.42) : Color(red: 0.20, green: 0.55, blue: 0.85),
                         secondary: bedtimeMode ? Color(red: 0.10, green: 0.18, blue: 0.38) : Color(red: 0.35, green: 0.48, blue: 0.82),
                         symbolName: "water.waves", accentSymbolName: "figure.walk")
        case "jacobs-ladder-dream":
            return .init(primary: bedtimeMode ? Color(red: 0.14, green: 0.16, blue: 0.38) : Color(red: 0.35, green: 0.40, blue: 0.82),
                         secondary: bedtimeMode ? Color(red: 0.35, green: 0.28, blue: 0.48) : Color(red: 0.70, green: 0.58, blue: 0.90),
                         symbolName: "ladder", accentSymbolName: "moon.stars.fill")
        case "gideons-brave-300":
            return .init(primary: bedtimeMode ? Color(red: 0.28, green: 0.22, blue: 0.12) : Color(red: 0.68, green: 0.55, blue: 0.30),
                         secondary: bedtimeMode ? Color(red: 0.38, green: 0.28, blue: 0.15) : Color(red: 0.82, green: 0.65, blue: 0.35),
                         symbolName: "light.max", accentSymbolName: "shield.fill")
        case "elijah-and-the-ravens":
            return .init(primary: bedtimeMode ? Color(red: 0.18, green: 0.22, blue: 0.32) : Color(red: 0.38, green: 0.48, blue: 0.68),
                         secondary: bedtimeMode ? Color(red: 0.30, green: 0.20, blue: 0.15) : Color(red: 0.65, green: 0.48, blue: 0.35),
                         symbolName: "bird.fill", accentSymbolName: "drop.fill")
        case "shadrach-meshach-abednego":
            return .init(primary: bedtimeMode ? Color(red: 0.42, green: 0.20, blue: 0.08) : Color(red: 0.90, green: 0.48, blue: 0.18),
                         secondary: bedtimeMode ? Color(red: 0.45, green: 0.32, blue: 0.10) : Color(red: 0.95, green: 0.70, blue: 0.25),
                         symbolName: "flame.fill", accentSymbolName: "person.3.fill")
        case "hannahs-prayer":
            return .init(primary: bedtimeMode ? Color(red: 0.28, green: 0.18, blue: 0.38) : Color(red: 0.62, green: 0.42, blue: 0.78),
                         secondary: bedtimeMode ? Color(red: 0.18, green: 0.28, blue: 0.38) : Color(red: 0.45, green: 0.62, blue: 0.82),
                         symbolName: "hands.sparkles.fill", accentSymbolName: "heart.fill")
        case "the-garden-of-eden":
            return .init(primary: bedtimeMode ? Color(red: 0.12, green: 0.30, blue: 0.18) : Color(red: 0.30, green: 0.70, blue: 0.40),
                         secondary: bedtimeMode ? Color(red: 0.28, green: 0.35, blue: 0.15) : Color(red: 0.60, green: 0.78, blue: 0.35),
                         symbolName: "tree.fill", accentSymbolName: "sun.max.fill")
        case "joseph-forgives-brothers":
            return .init(primary: bedtimeMode ? Color(red: 0.30, green: 0.22, blue: 0.42) : Color(red: 0.65, green: 0.48, blue: 0.85),
                         secondary: bedtimeMode ? Color(red: 0.42, green: 0.30, blue: 0.18) : Color(red: 0.88, green: 0.72, blue: 0.45),
                         symbolName: "heart.fill", accentSymbolName: "person.3.fill")
        case "miriams-song":
            return .init(primary: bedtimeMode ? Color(red: 0.22, green: 0.18, blue: 0.40) : Color(red: 0.52, green: 0.45, blue: 0.85),
                         secondary: bedtimeMode ? Color(red: 0.10, green: 0.28, blue: 0.38) : Color(red: 0.30, green: 0.62, blue: 0.80),
                         symbolName: "music.note", accentSymbolName: "water.waves")
        case "nehemiah-builds-wall":
            return .init(primary: bedtimeMode ? Color(red: 0.32, green: 0.25, blue: 0.15) : Color(red: 0.72, green: 0.58, blue: 0.38),
                         secondary: bedtimeMode ? Color(red: 0.20, green: 0.22, blue: 0.35) : Color(red: 0.48, green: 0.52, blue: 0.75),
                         symbolName: "building.2.fill", accentSymbolName: "hammer.fill")
        case "david-shepherd-boy":
            return .init(primary: bedtimeMode ? Color(red: 0.15, green: 0.28, blue: 0.22) : Color(red: 0.38, green: 0.68, blue: 0.52),
                         secondary: bedtimeMode ? Color(red: 0.28, green: 0.30, blue: 0.18) : Color(red: 0.65, green: 0.72, blue: 0.42),
                         symbolName: "leaf.fill", accentSymbolName: "music.note")
        case "solomon-asks-wisdom":
            return .init(primary: bedtimeMode ? Color(red: 0.35, green: 0.28, blue: 0.12) : Color(red: 0.78, green: 0.65, blue: 0.30),
                         secondary: bedtimeMode ? Color(red: 0.22, green: 0.18, blue: 0.38) : Color(red: 0.52, green: 0.45, blue: 0.80),
                         symbolName: "crown.fill", accentSymbolName: "lightbulb.fill")

        // New NT stories
        case "jesus-walks-on-water", "peter-walks-on-water":
            return .init(primary: bedtimeMode ? Color(red: 0.10, green: 0.22, blue: 0.42) : Color(red: 0.25, green: 0.52, blue: 0.88),
                         secondary: bedtimeMode ? Color(red: 0.15, green: 0.18, blue: 0.38) : Color(red: 0.40, green: 0.48, blue: 0.82),
                         symbolName: "water.waves", accentSymbolName: "figure.walk")
        case "the-mustard-seed":
            return .init(primary: bedtimeMode ? Color(red: 0.18, green: 0.30, blue: 0.15) : Color(red: 0.42, green: 0.70, blue: 0.38),
                         secondary: bedtimeMode ? Color(red: 0.32, green: 0.28, blue: 0.12) : Color(red: 0.72, green: 0.65, blue: 0.32),
                         symbolName: "leaf.fill", accentSymbolName: "tree.fill")
        case "jesus-heals-the-blind-man":
            return .init(primary: bedtimeMode ? Color(red: 0.32, green: 0.22, blue: 0.38) : Color(red: 0.70, green: 0.50, blue: 0.82),
                         secondary: bedtimeMode ? Color(red: 0.40, green: 0.32, blue: 0.15) : Color(red: 0.88, green: 0.72, blue: 0.38),
                         symbolName: "eye.fill", accentSymbolName: "sparkles")
        case "the-sower-and-the-seeds":
            return .init(primary: bedtimeMode ? Color(red: 0.22, green: 0.30, blue: 0.15) : Color(red: 0.52, green: 0.70, blue: 0.38),
                         secondary: bedtimeMode ? Color(red: 0.35, green: 0.28, blue: 0.12) : Color(red: 0.78, green: 0.65, blue: 0.32),
                         symbolName: "leaf.fill", accentSymbolName: "sun.max.fill")
        case "mary-and-martha":
            return .init(primary: bedtimeMode ? Color(red: 0.25, green: 0.18, blue: 0.35) : Color(red: 0.58, green: 0.42, blue: 0.75),
                         secondary: bedtimeMode ? Color(red: 0.15, green: 0.28, blue: 0.30) : Color(red: 0.40, green: 0.65, blue: 0.68),
                         symbolName: "house.fill", accentSymbolName: "heart.fill")
        case "the-ten-lepers":
            return .init(primary: bedtimeMode ? Color(red: 0.38, green: 0.28, blue: 0.15) : Color(red: 0.82, green: 0.65, blue: 0.38),
                         secondary: bedtimeMode ? Color(red: 0.18, green: 0.30, blue: 0.25) : Color(red: 0.42, green: 0.68, blue: 0.58),
                         symbolName: "hands.sparkles.fill", accentSymbolName: "heart.fill")
        case "jesus-in-the-garden-of-gethsemane":
            return .init(primary: bedtimeMode ? Color(red: 0.12, green: 0.18, blue: 0.28) : Color(red: 0.30, green: 0.42, blue: 0.62),
                         secondary: bedtimeMode ? Color(red: 0.18, green: 0.22, blue: 0.38) : Color(red: 0.42, green: 0.50, blue: 0.78),
                         symbolName: "tree.fill", accentSymbolName: "moon.fill")
        case "the-empty-tomb":
            return .init(primary: bedtimeMode ? Color(red: 0.35, green: 0.30, blue: 0.12) : Color(red: 0.82, green: 0.72, blue: 0.30),
                         secondary: bedtimeMode ? Color(red: 0.40, green: 0.28, blue: 0.15) : Color(red: 0.90, green: 0.65, blue: 0.35),
                         symbolName: "sun.max.fill", accentSymbolName: "sparkles")
        case "the-widows-offering":
            return .init(primary: bedtimeMode ? Color(red: 0.28, green: 0.20, blue: 0.35) : Color(red: 0.62, green: 0.45, blue: 0.75),
                         secondary: bedtimeMode ? Color(red: 0.38, green: 0.30, blue: 0.15) : Color(red: 0.82, green: 0.68, blue: 0.38),
                         symbolName: "hands.sparkles.fill", accentSymbolName: "heart.fill")
        case "jesus-and-the-woman-at-the-well":
            return .init(primary: bedtimeMode ? Color(red: 0.15, green: 0.28, blue: 0.38) : Color(red: 0.38, green: 0.62, blue: 0.80),
                         secondary: bedtimeMode ? Color(red: 0.30, green: 0.22, blue: 0.15) : Color(red: 0.68, green: 0.52, blue: 0.38),
                         symbolName: "drop.fill", accentSymbolName: "heart.fill")
        case "the-talents":
            return .init(primary: bedtimeMode ? Color(red: 0.35, green: 0.28, blue: 0.12) : Color(red: 0.78, green: 0.65, blue: 0.30),
                         secondary: bedtimeMode ? Color(red: 0.25, green: 0.20, blue: 0.38) : Color(red: 0.58, green: 0.48, blue: 0.80),
                         symbolName: "gift.fill", accentSymbolName: "sparkles")
        case "jesus-washes-the-disciples-feet":
            return .init(primary: bedtimeMode ? Color(red: 0.15, green: 0.25, blue: 0.35) : Color(red: 0.38, green: 0.58, blue: 0.75),
                         secondary: bedtimeMode ? Color(red: 0.22, green: 0.18, blue: 0.35) : Color(red: 0.52, green: 0.42, blue: 0.72),
                         symbolName: "drop.fill", accentSymbolName: "heart.fill")
        case "the-light-of-the-world":
            return .init(primary: bedtimeMode ? Color(red: 0.38, green: 0.30, blue: 0.12) : Color(red: 0.85, green: 0.72, blue: 0.30),
                         secondary: bedtimeMode ? Color(red: 0.18, green: 0.18, blue: 0.35) : Color(red: 0.45, green: 0.45, blue: 0.78),
                         symbolName: "light.max", accentSymbolName: "sparkles")

        default:
            return .init(primary: bedtimeMode ? Color(red: 0.18, green: 0.22, blue: 0.40) : Color(red: 0.46, green: 0.56, blue: 0.91),
                         secondary: bedtimeMode ? Color(red: 0.36, green: 0.26, blue: 0.44) : Color(red: 0.77, green: 0.63, blue: 0.92),
                         symbolName: "book.closed.fill", accentSymbolName: "moon.stars.fill")
        }
    }
}
