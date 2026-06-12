
import Foundation
import Combine
import MediaPlayer
import AVFoundation
import UIKit

@MainActor
final class AudioPlayerViewModel: ObservableObject {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 1
    @Published private(set) var currentStoryID: String?
    private(set) var currentStory: Story?
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

        setupRemoteCommands()
        setupInterruptionHandling()
    }

    // MARK: - Lock screen / Control Center (Now Playing)

    /// Registers remote commands so the lock screen, Control Center,
    /// AirPods, and CarPlay can drive playback.
    private func setupRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.play() }
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.pause() }
            return .success
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.isPlaying ? self.pause() : self.play()
            }
            return .success
        }
        center.skipForwardCommand.preferredIntervals = [15]
        center.skipForwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.skipForward() }
            return .success
        }
        center.skipBackwardCommand.preferredIntervals = [15]
        center.skipBackwardCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.skipBackward() }
            return .success
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            Task { @MainActor in self?.seekTo(time: event.positionTime) }
            return .success
        }
    }

    /// Publishes full story metadata to the lock screen.
    private func publishNowPlaying() {
        guard let story = currentStory else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: story.title,
            MPMediaItemPropertyArtist: "Firefly Bible Bedtime",
            MPMediaItemPropertyAlbumTitle: story.bibleReference,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        if let image = UIImage(named: story.id) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    /// Lightweight progress/rate update (play, pause, seek).
    private func updateNowPlayingProgress() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        info[MPMediaItemPropertyPlaybackDuration] = duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Interruption & route-change recovery

    /// Auto-resume after calls/Siri end; pause when headphones unplug.
    private func setupInterruptionHandling() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] note in
            guard let info = note.userInfo,
                  let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
            Task { @MainActor in
                guard let self else { return }
                switch type {
                case .began:
                    // Player is already paused by the system — mirror the state
                    self.isPlaying = false
                    self.updateNowPlayingProgress()
                case .ended:
                    let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt ?? 0
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume), self.currentStoryID != nil {
                        self.play()
                    }
                @unknown default:
                    break
                }
            }
        }

        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] note in
            guard let info = note.userInfo,
                  let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue),
                  reason == .oldDeviceUnavailable else { return }
            Task { @MainActor in
                // Headphones unplugged — pause rather than blast the room
                self?.pause()
            }
        }
    }

    func togglePlayback(for story: Story) {
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
        currentStory = story

        // 1. Try bundled MP3 first (instant, no network needed)
        do {
            try audioService.loadAudio(named: story.audioFileName)
            audioService.setVolume(narrationVolume)
            duration = max(audioService.duration, 1)
            currentTime = 0
            audioService.play()
            isPlaying = audioService.isPlaying
            startTimer()
            publishNowPlaying()
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
        if MPNowPlayingInfoCenter.default().nowPlayingInfo == nil {
            publishNowPlaying()
        } else {
            updateNowPlayingProgress()
        }
    }

    func pause() {
        audioService.pause()
        isPlaying = false
        stopTimer()
        currentTime = audioService.currentTime
        updateNowPlayingProgress()
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
        currentStory = nil
        publishNowPlaying()   // clears the lock-screen card
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
        updateNowPlayingProgress()
    }

    func skipBackward() {
        audioService.seek(by: -15)
        currentTime = audioService.currentTime
        updateNowPlayingProgress()
    }

    func seekTo(time: TimeInterval) {
        audioService.seekTo(time: time)
        currentTime = audioService.currentTime
        updateNowPlayingProgress()
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
