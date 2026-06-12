
import Foundation
import AVFoundation

/// Lets a grown-up record their own narration for a story, stored locally
/// per-child. Files live under Documents/ParentVoice/<profile>/<storyID>.m4a.
///
/// Audio-session isolation (CRITICAL — see CLAUDE.md "Critical Rules — Audio"):
/// the whole app runs on `.playback`. Recording temporarily needs
/// `.playAndRecord`. That category change is confined to `startRecording` here;
/// it is NOT changed anywhere else. The existing `setCategory(.playback…)` calls
/// inside `AudioPlaybackService.loadAudio` RESTORE `.playback` the next time a
/// story plays, so no global state leaks out of this service.
@MainActor
final class VoiceRecordingService: NSObject, ObservableObject {
    @Published private(set) var isRecording: Bool = false

    private var recorder: AVAudioRecorder?

    // MARK: - File locations

    /// Root folder for all parent recordings. Returns nil if the documents
    /// directory cannot be resolved (guarded — never force-unwrap; HANDOFF.md
    /// notes a prior force-unwrap bug here).
    static func parentVoiceRoot() -> URL? {
        guard let docs = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first else {
            return nil
        }
        return docs.appendingPathComponent("ParentVoice", isDirectory: true)
    }

    /// Folder name for a profile. Empty profile (no children yet) → "default".
    /// Sanitized so an unusual child name can't break the path.
    private static func folderName(for profile: String) -> String {
        let trimmed = profile.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "default" }
        let safe = trimmed.unicodeScalars.map { scalar -> Character in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : "_"
        }
        return String(safe)
    }

    /// The on-disk URL where this profile's recording for this story lives.
    /// Pure path math — no side effects, safe to call from anywhere (including
    /// the static lookup used by AudioPlayerViewModel).
    static func recordingURL(storyID: String, profile: String) -> URL? {
        guard let root = parentVoiceRoot() else { return nil }
        return root
            .appendingPathComponent(folderName(for: profile), isDirectory: true)
            .appendingPathComponent("\(storyID).m4a", isDirectory: false)
    }

    /// True when a saved recording exists for this story + profile.
    static func hasRecording(storyID: String, profile: String) -> Bool {
        guard let url = recordingURL(storyID: storyID, profile: profile) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    // Instance conveniences mirroring the statics (used by the UI).
    func recordingURL(storyID: String, profile: String) -> URL? {
        Self.recordingURL(storyID: storyID, profile: profile)
    }

    func hasRecording(storyID: String, profile: String) -> Bool {
        Self.hasRecording(storyID: storyID, profile: profile)
    }

    // MARK: - Microphone permission

    /// Requests microphone permission. Always call before `startRecording`.
    /// Uses the iOS 17 `AVAudioApplication` API (deployment target is iOS 17+).
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { granted in
            Task { @MainActor in completion(granted) }
        }
    }

    // MARK: - Recording

    /// Begins recording into the profile/story's file, creating folders as
    /// needed. Switches the session to `.playAndRecord` for the duration of the
    /// recording only — playback is restored on the next `loadAudio` call.
    @discardableResult
    func startRecording(storyID: String, profile: String) -> Bool {
        guard let url = Self.recordingURL(storyID: storyID, profile: profile) else {
            print("[ParentVoice] Could not resolve recording URL")
            return false
        }

        // Ensure the per-profile folder exists.
        let folder = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(
            at: folder, withIntermediateDirectories: true
        )

        // Isolated session change: recording needs input. Playback's own
        // setCategory flips this back to .playback the next time a story
        // loads, so nothing leaks out of this service. Failures are logged —
        // a silent category failure makes record() fail mysteriously below.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[ParentVoice] Audio session setup failed: \(error)")
        }

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            let r = try AVAudioRecorder(url: url, settings: settings)
            r.delegate = self
            guard r.record() else {
                print("[ParentVoice] record() returned false")
                // Remove the header-only stub AVAudioRecorder leaves behind —
                // a zero-length file here would silently shadow the bundled
                // narration in AudioPlayerViewModel.
                try? FileManager.default.removeItem(at: url)
                return false
            }
            recorder = r
            isRecording = true
            return true
        } catch {
            print("[ParentVoice] Failed to start recording: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: url)
            isRecording = false
            return false
        }
    }

    /// Stops the in-progress recording and finalizes the file.
    func stopRecording() {
        recorder?.stop()
        recorder = nil
        isRecording = false
    }

    /// Removes a saved recording for this story + profile.
    func deleteRecording(storyID: String, profile: String) {
        guard let url = Self.recordingURL(storyID: storyID, profile: profile) else { return }
        try? FileManager.default.removeItem(at: url)
    }

    /// Copies one child's recording of a story to another child's folder so a
    /// single take can serve several children. Overwrites any existing copy.
    @discardableResult
    func copyRecording(storyID: String, from source: String, to target: String) -> Bool {
        guard let src = Self.recordingURL(storyID: storyID, profile: source),
              let dst = Self.recordingURL(storyID: storyID, profile: target),
              FileManager.default.fileExists(atPath: src.path) else { return false }
        try? FileManager.default.createDirectory(
            at: dst.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try? FileManager.default.removeItem(at: dst)
        do {
            try FileManager.default.copyItem(at: src, to: dst)
            return true
        } catch {
            print("[ParentVoice] Copy to \(target) failed: \(error.localizedDescription)")
            return false
        }
    }
}

extension VoiceRecordingService: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        let url = recorder.url
        Task { @MainActor in
            self.isRecording = false
            // An unsuccessful finish leaves a broken file — remove it so it
            // can't shadow the bundled narration.
            if !flag { try? FileManager.default.removeItem(at: url) }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("[ParentVoice] Encode error: \(error?.localizedDescription ?? "unknown")")
        Task { @MainActor in self.isRecording = false }
    }
}
