
import SwiftUI

struct FeaturedStoryCard: View {
    let story: Story

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            StoryArtworkView(story: story, cornerRadius: 28)
                .frame(height: 220)
                .overlay {
                    LinearGradient(colors: [.clear, Color.black.opacity(0.22)], startPoint: .top, endPoint: .bottom)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Featured Tonight")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Text(story.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text(story.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.92))
                Text("\(story.listenDurationMinutes) min listen")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }
            .padding()
        }
    }
}
