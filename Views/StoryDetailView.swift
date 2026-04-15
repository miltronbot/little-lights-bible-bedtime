
import SwiftUI

struct StoryDetailView: View {
    let story: Story

    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var collectiblesManager: CollectiblesManager

    @State private var showSleepTimerSheet: Bool = false
    @State private var showAmbientSheet: Bool = false
    @State private var showAffirmations: Bool = false
    @State private var showScrollProgress: Bool = false
    @State private var scrollProgress: CGFloat = 0
    @State private var showCelebration: Bool = false
    @State private var lumiMessage: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero artwork with interactive touch overlay
                ZStack {
                    StoryArtworkView(story: story, cornerRadius: 24)
                        .frame(height: 220)
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 6) {
                                if let ageGroup = story.ageGroup {
                                    Text(ageGroup.rawValue)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial)
                                        .clipShape(Capsule())
                                }
                                Text(story.title)
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                                Text(story.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding()
                        }

                    // Interactive touch elements
                    if let touchElements = StoryTouchElements.elements(for: story.id) {
                        InteractiveTouchOverlay(elements: touchElements)
                            .allowsHitTesting(true)
                    }
                }
                .frame(height: 220)

                // Lumi mascot
                HStack(spacing: 8) {
                    LumiMascotView(size: 28, message: lumiMessage)
                    Button {
                        lumiMessage = LumiReaction.reaction(for: story.id)
                    } label: {
                        Text("Tap to say hi to Lumi ✨")
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                // Info bar
                HStack {
                    Label(story.bibleReference, systemImage: "book.closed")
                    Spacer()
                    Label("\(story.readDurationMinutes) min read", systemImage: "clock")
                    Spacer()
                    Label(story.category.rawValue, systemImage: story.category.icon)
                }
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                // Action buttons
                HStack(spacing: 12) {
                    Button {
                        print("🔴 BUTTON TAPPED - story: \(story.id)")
                        audioPlayerViewModel.togglePlayback(for: story)
                    } label: {
                        Label(
                            audioPlayerViewModel.currentStoryID == story.id && audioPlayerViewModel.isPlaying ? "Pause" : "Read to Me",
                            systemImage: audioPlayerViewModel.currentStoryID == story.id && audioPlayerViewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        favoritesViewModel.toggleFavorite(story)
                    } label: {
                        Image(systemName: favoritesViewModel.isFavorite(story) ? "heart.fill" : "heart")
                            .font(.title3)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(favoritesViewModel.isFavorite(story) ? .pink : AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .accessibilityLabel(favoritesViewModel.isFavorite(story) ? "Remove Favorite" : "Add Favorite")
                }

                // Quick Controls Row
                HStack(spacing: 10) {
                    Button { showSleepTimerSheet = true } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.title3)
                            Text(audioPlayerViewModel.sleepTimer.isActive ? audioPlayerViewModel.sleepTimer.remainingText : "Timer")
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            audioPlayerViewModel.sleepTimer.isActive
                                ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2)
                                : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                        )
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button { showAmbientSheet = true } label: {
                        VStack(spacing: 4) {
                            Image(systemName: audioPlayerViewModel.currentAmbientSound.icon)
                                .font(.title3)
                            Text(audioPlayerViewModel.currentAmbientSound == .none ? "Sounds" : audioPlayerViewModel.currentAmbientSound.displayName)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            audioPlayerViewModel.currentAmbientSound != .none
                                ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2)
                                : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                        )
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        appSettings.isBedtimeMode.toggle()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: appSettings.isBedtimeMode ? "moon.fill" : "sun.max.fill")
                                .font(.title3)
                            Text(appSettings.isBedtimeMode ? "Bedtime" : "Daytime")
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            appSettings.isBedtimeMode
                                ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2)
                                : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                        )
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Audio player bar
                AudioPlayerBar(story: story)

                if let errorMessage = audioPlayerViewModel.errorMessage,
                   audioPlayerViewModel.currentStoryID == nil {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                // Memory Verse
                if let verse = story.memoryVerse, !verse.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Memory Verse", systemImage: "text.quote")
                            .font(.headline)
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Text(verse)
                            .font(.system(size: 17, weight: .medium, design: .serif))
                            .italic()
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Story text with read-along highlighting
                VStack(alignment: .leading, spacing: 12) {
                    Text("Story")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    ReadAlongTextView(storyText: story.storyText)
                }

                // Takeaway
                VStack(alignment: .leading, spacing: 8) {
                    Label("Takeaway", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text(story.takeaway)
                        .font(.system(size: appSettings.fontSize))
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }

                // Discussion Questions
                DiscussionQuestionsView(story: story)

                // Bedtime Prayer
                VStack(alignment: .leading, spacing: 8) {
                    Label("Bedtime Prayer", systemImage: "hands.sparkles.fill")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text(story.bedtimePrayer)
                        .font(.system(size: appSettings.fontSize))
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Goodnight Affirmations Button
                if appSettings.isBedtimeMode {
                    Button {
                        showAffirmations = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Goodnight Affirmations")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                Text("Positive words before sleep")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.indigo.opacity(0.15), Color.purple.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }

                // Collectible preview
                if let collectible = collectiblesManager.collectibleForStory(story.id) {
                    HStack(spacing: 12) {
                        Text(collectible.emoji)
                            .font(.system(size: 32))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(collectible.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            Text(collectiblesManager.hasCollected(collectible.id) ? "Collected!" : "Complete this story to collect")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        }
                        Spacer()
                        if collectiblesManager.hasCollected(collectible.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Mark as read button
                Button {
                    let isAlreadyRead = readingStreak.streak.storiesReadDates.keys.contains(story.id)
                    readingStreak.recordStoryRead(storyID: story.id)
                    if !isAlreadyRead {
                        if let collectible = collectiblesManager.collectibleForStory(story.id) {
                            collectiblesManager.collect(collectible)
                        }
                        showCelebration = true
                    }
                } label: {
                    let isRead = readingStreak.streak.storiesReadDates.keys.contains(story.id)
                    Label(isRead ? "Completed" : "Mark as Read", systemImage: isRead ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isRead ? Color.green.opacity(0.15) : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                        .foregroundStyle(isRead ? .green : AppTheme.accent(for: appSettings.isBedtimeMode))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
        .navigationTitle(story.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            audioPlayerViewModel.stopIfPlaying(storyID: story.id)
        }
        .sheet(isPresented: $showSleepTimerSheet) {
            SleepTimerSheet()
                .environmentObject(appSettings)
                .environmentObject(audioPlayerViewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showAmbientSheet) {
            AmbientSoundSheet()
                .environmentObject(appSettings)
                .environmentObject(audioPlayerViewModel)
                .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showAffirmations) {
            GoodnightAffirmationsView()
                .environmentObject(appSettings)
        }
        .overlay {
            if showCelebration {
                let collectible = collectiblesManager.collectibleForStory(story.id)
                StoryCelebrationView(
                    collectibleName: collectible?.name,
                    collectibleEmoji: collectible?.emoji,
                    onDone: { showCelebration = false }
                )
                .environmentObject(appSettings)
            } else {
                Color.clear
                    .allowsHitTesting(false)
            }
        }
    }

    private var category: StoryCategory { story.category }
}

// MARK: - Sleep Timer Sheet

struct SleepTimerSheet: View {
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "timer")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))

                if audioPlayer.sleepTimer.isActive {
                    Text(audioPlayer.sleepTimer.remainingText)
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    Button("Stop Timer") {
                        audioPlayer.stopSleepTimer()
                        dismiss()
                    }
                    .foregroundStyle(.red)
                } else {
                    Text("Set Sleep Timer")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    ForEach(SleepTimerService.presetMinutes, id: \.self) { minutes in
                        Button {
                            audioPlayer.startSleepTimer(minutes: minutes)
                            dismiss()
                        } label: {
                            Text("\(minutes) minutes")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
            }
            .padding()
            .background(AppTheme.background(for: appSettings.isBedtimeMode))
            .navigationTitle("Sleep Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Ambient Sound Sheet

struct AmbientSoundSheet: View {
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // STOP button — big and prominent when playing
                if audioPlayer.currentAmbientSound != .none {
                    Button {
                        audioPlayer.setAmbientSound(.none)
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "stop.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Stop Ambient Sound")
                                    .font(.headline.bold())
                                    .foregroundStyle(.white)
                                Text("Currently: \(audioPlayer.currentAmbientSound.displayName)")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        .padding(18)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    // Volume slider
                    HStack(spacing: 10) {
                        Image(systemName: "speaker.fill")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        Slider(value: Binding(
                            get: { Double(audioPlayer.ambientVolume) },
                            set: { audioPlayer.setAmbientVolume(Float($0)) }
                        ), in: 0...1)
                        .tint(AppTheme.accent(for: appSettings.isBedtimeMode))
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }
                    .padding(.horizontal, 4)

                    Divider()
                        .padding(.vertical, 4)
                }

                // Sound options (exclude .none since we have the stop button)
                ForEach(AmbientSound.allCases.filter { $0 != .none }) { sound in
                    Button {
                        audioPlayer.setAmbientSound(sound)
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(audioPlayer.currentAmbientSound == sound
                                        ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                        : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                                    .frame(width: 44, height: 44)
                                Image(systemName: sound.icon)
                                    .font(.system(size: 18))
                                    .foregroundStyle(audioPlayer.currentAmbientSound == sound
                                        ? .white
                                        : AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            }
                            Text(sound.displayName)
                                .font(.headline)
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            Spacer()
                            if audioPlayer.currentAmbientSound == sound {
                                Image(systemName: "waveform")
                                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                                    .symbolEffect(.variableColor.iterative)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            audioPlayer.currentAmbientSound == sound
                                ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.08)
                                : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding()
            .background(AppTheme.background(for: appSettings.isBedtimeMode))
            .navigationTitle("Ambient Sounds")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
