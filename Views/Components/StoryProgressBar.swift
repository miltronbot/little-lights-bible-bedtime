
import SwiftUI

// MARK: - Reading Progress Bar
// Shows reading progress at the top of the story detail view

struct StoryProgressBar: View {
    let progress: CGFloat // 0.0 to 1.0
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.12))

                // Fill
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.accent(for: appSettings.isBedtimeMode),
                                AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * min(max(progress, 0), 1))
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 3)
    }
}

// MARK: - Animated Story Section Header
// Section headers that fade in when scrolled into view

struct AnimatedSectionHeader: View {
    let title: String
    let icon: String
    @EnvironmentObject private var appSettings: AppSettings

    @State private var appeared: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
            Text(title)
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
        }
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
        }
    }
}

// MARK: - Story Completion Celebration
// Shown when a story is marked as read

struct StoryCompletionView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @State private var showStars: Bool = false
    @State private var showText: Bool = false
    // Fixed offsets generated once on appear — prevents positions from changing on re-render
    @State private var starOffsets: [(CGFloat, CGFloat)] = []

    var body: some View {
        VStack(spacing: 16) {
            // Stars burst animation
            ZStack {
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                        .offset(
                            x: showStars && i < starOffsets.count ? starOffsets[i].0 : 0,
                            y: showStars && i < starOffsets.count ? starOffsets[i].1 : 0
                        )
                        .opacity(showStars ? 1.0 : 0.0)
                        .scaleEffect(showStars ? 1.0 : 0.3)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.6)
                            .delay(Double(i) * 0.1),
                            value: showStars
                        )
                }

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)
                    .scaleEffect(showStars ? 1.0 : 0.5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.5), value: showStars)
            }

            if showText {
                VStack(spacing: 4) {
                    Text("Story Complete!")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("+1 Sleep Star earned")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .onAppear {
            // Generate fixed offsets once so they stay stable across re-renders
            starOffsets = (0..<5).map { _ in
                (CGFloat.random(in: -40...40), CGFloat.random(in: -40...40))
            }
            withAnimation {
                showStars = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showText = true
                }
            }
        }
    }
}
