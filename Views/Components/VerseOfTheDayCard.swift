import SwiftUI

// MARK: - Verse of the Day
// A daily-rotating memory verse on Home, drawn from the 45 stories that
// carry one. Deterministic by day-of-year so the whole family sees the
// same verse all day. Tapping opens the verse's story.

struct VerseOfTheDayCard: View {
    @EnvironmentObject private var library: StoryLibraryViewModel
    @EnvironmentObject private var appSettings: AppSettings

    private var todaysStory: Story? {
        let candidates = library.stories.filter { ($0.memoryVerse ?? "").isEmpty == false }
        guard !candidates.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return candidates[day % candidates.count]
    }

    var body: some View {
        if let story = todaysStory, let verse = story.memoryVerse {
            NavigationLink(destination: StoryDetailView(story: story)) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Verse of the Day", systemImage: "sun.and.horizon.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.yellow)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }

                    Text(verse)
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("from \u{201C}\(story.title)\u{201D}")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.16, green: 0.22, blue: 0.22), Color(red: 0.08, green: 0.14, blue: 0.16)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Story Postcard
// A shareable keepsake image: story artwork, memory verse, and the app
// name — perfect for sending to grandparents. Rendered offscreen with
// ImageRenderer at 1080×1350.

struct PostcardView: View {
    let story: Story

    var body: some View {
        ZStack(alignment: .bottom) {
            if let ui = UIImage(named: story.id) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 1080, height: 1350)
                    .clipped()
            } else {
                Color(red: 0.05, green: 0.13, blue: 0.16)
                    .frame(width: 1080, height: 1350)
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center, endPoint: .bottom
            )

            VStack(spacing: 22) {
                Text(story.title)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                if let verse = story.memoryVerse, !verse.isEmpty {
                    Text(verse)
                        .font(.system(size: 34, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                }

                Text("✨ Firefly Bible Bedtime")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.yellow.opacity(0.9))
            }
            .padding(.bottom, 70)
        }
        .frame(width: 1080, height: 1350)
    }
}

enum PostcardRenderer {
    @MainActor
    static func render(story: Story) -> UIImage? {
        let renderer = ImageRenderer(content: PostcardView(story: story))
        renderer.scale = 1
        return renderer.uiImage
    }
}
