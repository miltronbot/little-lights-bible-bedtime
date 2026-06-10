
import Foundation
import Combine

@MainActor
final class AudioPlayerViewModel: ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 1
    @Published private(set) var currentStoryID: String?
    @Published var errorMessage: String?
    @Published private(set) var isGeneratingAudio: Bool = false

    // Sleep Timer — @Published so views re-render instantly on changes
    @Published var sleepTimer = SleepTimerService()
    private var sleepTimerCancellable: AnyCancellable?

    // Ambient Sound
    private let ambientService = AmbientSoundService()
    @Published var currentAmbientSound: AmbientSound = .none
    @Published var ambientVolume: Float = 0.3
    @Published var narrationVolume: Float = 1.0

    private let audioService = AudioPlaybackService()
    private var timerCancellable: AnyCancellable?
    private var currentFadeID: UUID = UUID()
    private var loadTask: Task<Void, Never>?

    // Callback when a story finishes (for streak tracking)
    var onStoryFinished: ((String) -> Void)?

    // Tonight's Queue — stories that auto-play back-to-back, then flow
    // into ambient sound / sleep timer
    @Published private(set) var storyQueue: [Story] = []
    static let maxQueueLength = 3

    init() {
        audioService.onPlaybackFinished = { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                if let storyID = self.currentStoryID {
                    self.onStoryFinished?(storyID)
                }
                self.isPlaying = false
                self.currentTime = 0

                // Auto-advance through Tonight's Queue after a calm pause
                if let next = self.storyQueue.first {
                    self.storyQueue.removeFirst()
                    try? await Task.sleep(for: .seconds(1.5))
                    guard !self.isPlaying else { return }  // user started something else
                    self.loadAndPlay(story: next)
                }
            }
        }

        sleepTimer.onTimerExpired = { [weak self] in
            Task { @MainActor in
                self?.fadeOutAndStop()
            }
        }

        // Forward timer changes so ContentView re-renders every second
        sleepTimerCancellable = sleepTimer.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }

    func togglePlayback(for story: Story) {
        print("[AudioPlayerViewModel] *** TOGGLE CALLED: \(story.id) ***")
        if currentStoryID == story.id && isPlaying {
            pause()
            return
        }
        if currentStoryID == story.id && !isPlaying && audioService.duration > 0 {
            play()
            return
        }
        loadAndPlay(story: story)
    }



    func loadAndPlay(story: Story) {
        // Cancel any in-flight load to prevent stale tasks updating state
        loadTask?.cancel()
        loadTask = Task {
            await loadAndPlayAsync(story: story)
        }
    }

    func loadAndPlayAsync(story: Story) async {
        errorMessage = nil
        audioService.stop()
        audioService.setVolume(narrationVolume)
        isPlaying = false
        currentTime = 0
        currentStoryID = story.id

        // 1. Try bundled MP3 first (instant, no network needed)
        do {
            try audioService.loadAudio(named: story.audioFileName)
            audioService.setVolume(narrationVolume)
            duration = max(audioService.duration, 1)
            currentTime = 0
            let result = audioService.play()
            isPlaying = audioService.isPlaying
            startTimer()
            print("[AudioPlayerViewModel] play() result=\(result) isPlaying=\(isPlaying) duration=\(duration)")
            return
        } catch {
            print("[AudioPlayerViewModel] Bundled audio not found: \(story.audioFileName) — \(error.localizedDescription)")
        }

        // 2. Try ElevenLabs (cached or API)
        let apiKey = UserDefaults.standard.string(forKey: "elevenLabsAPIKey") ?? ""
        // Use per-story resolved voice (character → narrator → default)
        let voiceID = story.resolvedVoiceID

        // Check cache first — no loading spinner needed
        if let cached = ElevenLabsService.shared.cachedURL(storyID: story.id, voiceID: voiceID) {
            guard !Task.isCancelled else { currentStoryID = nil; return }
            do {
                try audioService.loadAudio(from: cached)
                audioService.setVolume(narrationVolume)
                duration = max(audioService.duration, 1)
                currentTime = 0
                play()
            } catch {
                errorMessage = error.localizedDescription
                currentStoryID = nil
            }
            return
        }

        // Not cached — call API, show loading indicator
        guard !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Add your ElevenLabs API key in Settings → Voice Narration to enable audio."
            currentStoryID = nil
            return
        }

        isGeneratingAudio = true
        defer { isGeneratingAudio = false }

        do {
            let audioURL = try await ElevenLabsService.shared.generateAudio(
                storyID: story.id,
                text: story.storyText,
                voiceID: voiceID,
                apiKey: apiKey
            )
            guard !Task.isCancelled else { currentStoryID = nil; return }
            try audioService.loadAudio(from: audioURL)
            audioService.setVolume(narrationVolume)
            duration = max(audioService.duration, 1)
            currentTime = 0
            play()
        } catch {
            if !Task.isCancelled {
                errorMessage = error.localizedDescription
                currentStoryID = nil
            }
        }
    }

    func play() {
        audioService.play()
        isPlaying = true
        startTimer()
    }

    func pause() {
        audioService.pause()
        isPlaying = false
        stopTimer()
        currentTime = audioService.currentTime
    }

    func stop() {
        loadTask?.cancel()         // Cancel any in-flight audio load
        loadTask = nil
        currentFadeID = UUID()     // Invalidate any in-progress fade-out
        audioService.stop()
        audioService.setVolume(narrationVolume) // Restore configured volume
        isPlaying = false
        isGeneratingAudio = false
        stopTimer()
        currentTime = 0
        duration = max(audioService.duration, 1)
        currentStoryID = nil
    }

    func stopIfPlaying(storyID: String) {
        guard currentStoryID == storyID else { return }
        stop()
    }

    // MARK: - Tonight's Queue

    func isQueued(_ story: Story) -> Bool {
        storyQueue.contains { $0.id == story.id }
    }

    func toggleQueued(_ story: Story) {
        if isQueued(story) {
            storyQueue.removeAll { $0.id == story.id }
        } else {
            guard storyQueue.count < Self.maxQueueLength else { return }
            storyQueue.append(story)
        }
    }

    func removeFromQueue(_ story: Story) {
        storyQueue.removeAll { $0.id == story.id }
    }

    func clearQueue() {
        storyQueue = []
    }

    func skipForward() {
        audioService.seek(by: 15)
        currentTime = audioService.currentTime
    }

    func skipBackward() {
        audioService.seek(by: -15)
        currentTime = audioService.currentTime
    }

    func seekTo(time: TimeInterval) {
        audioService.seekTo(time: time)
        currentTime = audioService.currentTime
    }

    // MARK: - Sleep Timer

    func startSleepTimer(minutes: Int) {
        sleepTimer.start(minutes: minutes)
    }

    func stopSleepTimer() {
        sleepTimer.stop()
    }

    // MARK: - Ambient Sound

    func setAmbientSound(_ sound: AmbientSound) {
        if sound == .none {
            ambientService.stop()
            currentAmbientSound = .none
        } else {
            ambientService.play(sound: sound, volume: ambientVolume)
            // Reflect the service's actual state — .none if file wasn't found
            currentAmbientSound = ambientService.currentSound
        }
    }

    func setAmbientVolume(_ volume: Float) {
        ambientVolume = volume
        ambientService.setVolume(volume)
    }

    // MARK: - Narration Volume

    func setNarrationVolume(_ volume: Float) {
        narrationVolume = volume
        audioService.setVolume(volume)
    }

    // MARK: - Fade Out

    private func fadeOutAndStop() {
        // Fade narration volume over 10 seconds from current volume.
        // Uses a fade ID so that if stop() is called before the fade completes,
        // all pending blocks become no-ops.
        let fadeID = UUID()
        currentFadeID = fadeID

        let steps = 40
        let interval = 10.0 / Double(steps)
        let startVolume = narrationVolume

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) { [weak self] in
                guard let self = self, self.currentFadeID == fadeID else { return }
                let factor = Float(steps - i) / Float(steps)
                self.audioService.setVolume(startVolume * factor)
            }
        }

        // Also fade ambient
        ambientService.fadeOut(duration: 10.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            guard let self = self, self.currentFadeID == fadeID else { return }
            self.stop()
        }
    }

    // MARK: - Computed

    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    var currentTimeText: String { formatTime(currentTime) }
    var durationText: String { formatTime(duration) }

    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: 0.25, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.currentTime = self.audioService.currentTime
                self.duration = max(self.audioService.duration, 1)
                self.isPlaying = self.audioService.isPlaying
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time.rounded(.down))
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
