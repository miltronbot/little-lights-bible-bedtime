import SwiftUI
import AVFoundation

struct BedtimeRoutineView: View {
    @EnvironmentObject private var viewModel: StoryLibraryViewModel
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel

    @State private var currentStep: Int = 0
    @State private var selectedTimerMinutes: Int = 5
    @State private var selectedAmbient: AmbientSound = .rain
    @State private var previewingSound: AmbientSound? = nil
    @State private var previewPlayer: AVAudioPlayer? = nil
    @State private var routineStarted: Bool = false
    @State private var breathsCompleted: Int = 0
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack {
            // Background
            StarryNightBackground(alwaysStarry: true)

            VStack(spacing: 0) {
                if !routineStarted {
                    // Pre-routine settings screen
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            VStack(spacing: 8) {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                                Text("Bedtime Routine")
                                    .font(.title.bold())
                                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                Text("A magical guided experience before sleep")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top)

                            // Tonight's Story
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Tonight's Story", systemImage: "1.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                                if let story = viewModel.tonightsStory {
                                    StoryCardView(story: story)
                                }
                            }

                            // Sleep Timer
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Sleep Timer", systemImage: "2.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                                HStack(spacing: 10) {
                                    ForEach(SleepTimerService.presetMinutes, id: \.self) { minutes in
                                        Button {
                                            selectedTimerMinutes = minutes
                                        } label: {
                                            Text("\(minutes) min")
                                                .font(.subheadline.bold())
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 12)
                                                .background(
                                                    selectedTimerMinutes == minutes
                                                        ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                                        : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                                                )
                                                .foregroundStyle(
                                                    selectedTimerMinutes == minutes
                                                        ? .white
                                                        : AppTheme.primaryText(for: appSettings.isBedtimeMode)
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }

                            // Ambient Sound
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Ambient Sound", systemImage: "3.circle.fill")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                    ForEach(AmbientSound.allCases.filter { $0 != .none }) { sound in
                                        Button {
                                            selectedAmbient = sound
                                        } label: {
                                            VStack(spacing: 6) {
                                                // Icon row with preview button
                                                HStack(spacing: 4) {
                                                    Image(systemName: sound.icon)
                                                        .font(.title3)
                                                    Spacer()
                                                    // Preview play/stop button
                                                    Button {
                                                        togglePreview(sound)
                                                    } label: {
                                                        Image(systemName: previewingSound == sound ? "stop.circle.fill" : "play.circle")
                                                            .font(.caption)
                                                            .foregroundStyle(
                                                                selectedAmbient == sound ? .white.opacity(0.9) : AppTheme.accent(for: appSettings.isBedtimeMode)
                                                            )
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                                .padding(.horizontal, 8)
                                                Text(sound.displayName)
                                                    .font(.caption2)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 6)
                                            .background(
                                                selectedAmbient == sound
                                                    ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                                    : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                                            )
                                            .foregroundStyle(
                                                selectedAmbient == sound
                                                    ? .white
                                                    : AppTheme.primaryText(for: appSettings.isBedtimeMode)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                // Pulsing ring when previewing
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(previewingSound == sound ? 0.8 : 0), lineWidth: 2)
                                            )
                                        }
                                    }
                                }
                            }

                            // Start Button
                            Button {
                                startRoutine()
                            } label: {
                                Label("Begin Guided Routine", systemImage: "play.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [.indigo, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                            }
                        }
                        .padding()
                    }
                } else {
                    // Guided routine flow
                    GuidedRoutineFlowView(
                        currentStep: $currentStep,
                        breathsCompleted: $breathsCompleted,
                        childName: appSettings.activeChildName,
                        onComplete: {
                            routineStarted = false
                            audioPlayer.setAmbientSound(.none)
                            audioPlayer.stopSleepTimer()
                            audioPlayer.stop()
                        }
                    )
                }
            }
        }
        .navigationTitle("Bedtime Routine")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !appSettings.isBedtimeMode {
                appSettings.isBedtimeMode = true
            }
        }
    }


    // MARK: - Ambient Sound Preview

    private func togglePreview(_ sound: AmbientSound) {
        // If already previewing this sound, stop it
        if previewingSound == sound {
            previewPlayer?.stop()
            previewPlayer = nil
            previewingSound = nil
            return
        }

        // Stop any current preview
        previewPlayer?.stop()
        previewPlayer = nil
        previewingSound = nil

        // Play the sound file as a short preview (5 seconds then auto-stop)
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.7
            player.prepareToPlay()
            player.play()
            previewPlayer = player
            previewingSound = sound

            // Auto-stop preview after 6 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) { [self] in
                if previewingSound == sound {
                    previewPlayer?.stop()
                    previewPlayer = nil
                    previewingSound = nil
                }
            }
        } catch {
            print("[BedtimeRoutine] Preview failed: \(error)")
        }
    }

    private func startRoutine() {
        routineStarted = true
        currentStep = 0
        breathsCompleted = 0
        appSettings.isBedtimeMode = true

        // Start sleep timer and ambient sound
        audioPlayer.startSleepTimer(minutes: selectedTimerMinutes)
        audioPlayer.setAmbientSound(selectedAmbient)
    }

}

// MARK: - Guided Routine Flow

struct GuidedRoutineFlowView: View {
    @Binding var currentStep: Int
    @Binding var breathsCompleted: Int
    let childName: String
    let onComplete: () -> Void

    @EnvironmentObject private var viewModel: StoryLibraryViewModel
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings

    private var story: Story? { viewModel.tonightsStory }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicatorView(currentStep: currentStep, totalSteps: 4)
                    .padding()

                // Step content — single view per step (no TabView paging)
                Group {
                    switch currentStep {
                    case 0:
                        BreathingStepView(
                            breathsCompleted: $breathsCompleted,
                            onSkip: { withAnimation { currentStep = 1 } }
                        )
                    case 1:
                        if let story {
                            StoryStepView(
                                story: story,
                                onContinue: { withAnimation { currentStep = 2 } }
                            )
                        }
                    case 2:
                        if let story {
                            PrayerStepView(
                                prayerText: story.bedtimePrayer,
                                onContinue: { withAnimation { currentStep = 3 } }
                            )
                        }
                    case 3:
                        GoodnightStepView(
                            childName: childName,
                            onDismiss: onComplete
                        )
                    default:
                        EmptyView()
                    }
                }
                .frame(maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id(currentStep)

                // Bottom action bar
                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button {
                            withAnimation { currentStep -= 1 }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button {
                        if currentStep < 3 {
                            withAnimation { currentStep += 1 }
                        } else {
                            onComplete()
                        }
                    } label: {
                        Text(currentStep == 3 ? "Close Routine" : "Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Step 1: Breathing Exercise

struct BreathingStepView: View {
    @Binding var breathsCompleted: Int
    let onSkip: () -> Void

    @EnvironmentObject private var appSettings: AppSettings
    @State private var isBreathingIn: Bool = true
    @State private var isBreathCycleActive: Bool = false
    @State private var breathPhaseText: String = ""
    @State private var breathingTask: Task<Void, Never>? = nil

    let breathingInDuration: Double = 4
    let holdDuration: Double = 4
    let breathingOutDuration: Double = 4

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            VStack(spacing: 12) {
                Text("Time to Wind Down")
                    .font(.title.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                Text("Take 3 deep, calming breaths")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            // Breathing circle animation
            VStack(spacing: 20) {
                ZStack {
                    // Outer circle background
                    Circle()
                        .stroke(
                            AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2),
                            lineWidth: 2
                        )
                        .frame(height: 240)

                    // Animated breathing circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.6),
                                    AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(
                            height: isBreathingIn ? 160 : (isBreathCycleActive ? 100 : 140)
                        )
                }

                // Breathing instruction text
                Text(breathPhaseText)
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .frame(height: 24)

                // Progress
                Text("Breath \(breathsCompleted + 1) of 3")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            Spacer()

            // Skip button
            Button {
                breathingTask?.cancel()
                onSkip()
            } label: {
                Text("Skip to Next Step")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
        }
        .padding(40)
        .onAppear {
            startBreathingCycle()
        }
        .onDisappear {
            breathingTask?.cancel()
            breathingTask = nil
        }
    }

    private func startBreathingCycle() {
        breathingTask?.cancel()
        breathingTask = Task { @MainActor in
            isBreathCycleActive = true

            while breathsCompleted < 3 {
                guard !Task.isCancelled else { return }

                // Breathe in
                withAnimation(.easeInOut(duration: breathingInDuration)) {
                    isBreathingIn = true
                    breathPhaseText = "Breathe in..."
                }
                try? await Task.sleep(nanoseconds: UInt64(breathingInDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }

                // Hold
                withAnimation(.easeInOut(duration: holdDuration)) {
                    breathPhaseText = "Hold..."
                }
                try? await Task.sleep(nanoseconds: UInt64(holdDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }

                // Breathe out
                withAnimation(.easeInOut(duration: breathingOutDuration)) {
                    isBreathingIn = false
                    breathPhaseText = "Breathe out..."
                }
                try? await Task.sleep(nanoseconds: UInt64(breathingOutDuration * 1_000_000_000))
                guard !Task.isCancelled else { return }

                breathsCompleted += 1

                if breathsCompleted < 3 {
                    // Brief pause between cycles
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }

            guard !Task.isCancelled else { return }
            withAnimation {
                breathPhaseText = "You're ready..."
            }
        }
    }
}

// MARK: - Step 2: Story Time

struct StoryStepView: View {
    let story: Story
    let onContinue: () -> Void

    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @State private var hasLoadedStory: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            // Story artwork
            StoryArtworkView(story: story, cornerRadius: 16)
                .frame(height: 200)
                .padding()

            // Story title
            Text(story.title)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Now playing indicator
            HStack(spacing: 8) {
                Image(systemName: "waveform")
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .symbolEffect(.variableColor)

                Text(audioPlayer.isPlaying ? "Story playing..." : "Ready to play...")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                Spacer()

                // Play/Pause button
                Button {
                    if audioPlayer.isPlaying {
                        audioPlayer.pause()
                    } else {
                        audioPlayer.play()
                    }
                } label: {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                }
            }
            .padding()
            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding()

            // Story text (scrollable)
            ScrollView {
                Text(story.storyText)
                    .font(.system(size: appSettings.fontSize))
                    .lineSpacing(6)
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    .padding()
            }

            Spacer(minLength: 20)

            // Continue button
            Button {
                onContinue()
            } label: {
                Text("Continue to Prayer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .onAppear {
            if !hasLoadedStory {
                audioPlayer.loadAndPlay(story: story)
                hasLoadedStory = true
            }
        }
    }
}

// MARK: - Step 3: Bedtime Prayer

struct PrayerStepView: View {
    let prayerText: String
    let onContinue: () -> Void

    @EnvironmentObject private var appSettings: AppSettings
    @State private var showPrayer: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Title
            Text("Bedtime Prayer")
                .font(.title.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            // Prayer card
            VStack(spacing: 16) {
                ScrollView {
                    Text(prayerText)
                        .font(.system(size: appSettings.fontSize))
                        .lineSpacing(6)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                }

                HStack(spacing: 8) {
                    Image(systemName: "hands.sparkles")
                        .font(.title3)
                    Text("Take your time")
                        .font(.caption)
                }
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
            .padding(24)
            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
            .opacity(showPrayer ? 1 : 0)
            .onAppear {
                withAnimation(.easeIn(duration: 1)) {
                    showPrayer = true
                }
            }

            Spacer()

            // Amen button
            Button {
                onContinue()
            } label: {
                Text("Amen")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [.indigo, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding()
        }
    }
}

// MARK: - Step 4: Goodnight Affirmation

struct GoodnightStepView: View {
    let childName: String
    let onDismiss: () -> Void

    @EnvironmentObject private var appSettings: AppSettings
    @State private var affirmation: String = ""
    @State private var showAffirmation: Bool = false
    @State private var glowOpacity: Double = 0.3

    let affirmations = [
        "You are brave and strong.",
        "You are loved beyond measure.",
        "Your light shines brightly.",
        "You are God's precious creation.",
        "Rest well, tomorrow brings joy.",
        "You are protected and safe.",
        "You are kind and caring.",
        "Your dreams are wonderful.",
        "You are exactly who you're meant to be.",
        "God watches over you always."
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Star animation background
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.accent(for: appSettings.isBedtimeMode).opacity(glowOpacity),
                                .clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 160
                        )
                    )
                    .frame(height: 320)
                    .opacity(showAffirmation ? 1 : 0)

                // Star icon
                VStack(spacing: 20) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .opacity(showAffirmation ? 1 : 0)

                    Text(affirmation)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .opacity(showAffirmation ? 1 : 0)
                }
            }

            // Personalized greeting
            Text(!childName.isEmpty ? "Goodnight, \(childName)!" : "Sweet dreams!")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .opacity(showAffirmation ? 1 : 0)

            Spacer()

            // Dismiss button
            Button {
                onDismiss()
            } label: {
                Text("Sweet Dreams")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding()

            Spacer(minLength: 20)
        }
        .onAppear {
            affirmation = affirmations.randomElement() ?? "You are loved."
            withAnimation(.easeIn(duration: 1.5)) {
                showAffirmation = true
            }

            // Pulse glow animation
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowOpacity = 0.8
            }
        }
    }
}

// MARK: - Progress Indicator

struct ProgressIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int

    @EnvironmentObject private var appSettings: AppSettings

    let stepLabels = ["Breathing", "Story", "Prayer", "Goodnight"]

    var body: some View {
        VStack(spacing: 12) {
            // Step dots
            HStack(spacing: 12) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Circle()
                        .fill(
                            step <= currentStep
                                ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                        )
                        .frame(height: 12)
                }
            }

            // Current step label
            Text(stepLabels[min(currentStep, totalSteps - 1)])
                .font(.caption.bold())
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
        }
    }
}

// MARK: - Active Routine View (Simplified)

struct ActiveRoutineView: View {
    let timerMinutes: Int
    let ambientSound: AmbientSound
    let onStop: () -> Void

    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 20) {
            // Timer display
            if audioPlayer.sleepTimer.isActive {
                VStack(spacing: 8) {
                    Text("Sleep Timer")
                        .font(.headline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                    Text(audioPlayer.sleepTimer.remainingText)
                        .font(.system(size: 48, weight: .light, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    ProgressView(value: audioPlayer.sleepTimer.progress)
                        .tint(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .padding(.horizontal)
                }
                .padding()
                .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            // Now playing indicator
            if audioPlayer.isPlaying {
                HStack(spacing: 12) {
                    Image(systemName: "waveform")
                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .symbolEffect(.variableColor)
                    Text("Story is playing...")
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Spacer()
                    Button { audioPlayer.pause() } label: {
                        Image(systemName: "pause.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    }
                }
                .padding()
                .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // Ambient indicator
            HStack {
                Image(systemName: ambientSound.icon)
                Text(ambientSound.displayName)
                Spacer()
                Text("Playing")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            .padding()
            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Add time button
            Button {
                audioPlayer.sleepTimer.addTime(minutes: 15)
            } label: {
                Label("Add 15 Minutes", systemImage: "plus.circle")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            // Stop button
            Button {
                audioPlayer.stop()
                audioPlayer.stopSleepTimer()
                audioPlayer.setAmbientSound(.none)
                onStop()
            } label: {
                Label("End Routine", systemImage: "stop.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}
