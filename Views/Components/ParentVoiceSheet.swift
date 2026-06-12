
import SwiftUI
import AVFoundation

/// Parent Voice — lets a grown-up record their own narration for a story.
/// Once saved, that recording plays INSTEAD of the bundled narration for the
/// active child (see AudioPlayerViewModel).
///
/// Presented as a `.sheet` from StoryDetailView (never a fullScreenCover) so it
/// stays out of the StoryDetailView.onDisappear audio-stop guard.
/// Parent-gated, gentle copy, never auto-records (COPPA).
struct ParentVoiceSheet: View {
    let story: Story

    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @Environment(\.dismiss) private var dismiss

    @StateObject private var recorder = VoiceRecordingService()

    @State private var hasRecording: Bool = false
    @State private var permissionDenied: Bool = false
    @State private var recordingFailed: Bool = false
    /// Other children who also have this recording (file exists in their folder).
    @State private var sharedWith: Set<String> = []
    @State private var previewPlayer: AVAudioPlayer?
    @State private var isPreviewing: Bool = false

    private var profile: String { appSettings.activeChildName }

    /// The other children this recording could be shared with.
    private var otherChildren: [String] {
        appSettings.childrenNames.filter { $0 != profile }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    // Friendly header
                    VStack(spacing: 10) {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                        Text("Record Your Voice")
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Text("Read \"\(story.title)\" aloud and your little one will hear your voice instead of our narrator.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 8)

                    if permissionDenied {
                        Text("Microphone access is off. Turn it on in Settings → Firefly → Microphone to record.")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.orange)
                            .padding(.horizontal)
                    } else if recordingFailed {
                        Text("The microphone isn't ready right now. Please try again in a moment.")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.orange)
                            .padding(.horizontal)
                    }

                    // Record / Stop
                    Button {
                        recorder.isRecording ? stopRecording() : beginRecording()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: recorder.isRecording ? "stop.circle.fill" : "record.circle")
                                .font(.system(size: 26))
                            Text(recorder.isRecording ? "Stop Recording" : (hasRecording ? "Record Again" : "Start Recording"))
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(recorder.isRecording ? Color.red : AppTheme.accent(for: appSettings.isBedtimeMode))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    if recorder.isRecording {
                        Label("Recording… read gently and clearly.", systemImage: "waveform")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            .symbolEffect(.variableColor.iterative)
                    }

                    // Saved-recording controls
                    if hasRecording && !recorder.isRecording {
                        VStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.green)
                                Text("Your recording is saved for \(profile.isEmpty ? "this child" : profile).")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                Spacer()
                            }

                            Button {
                                isPreviewing ? stopPreview() : startPreview()
                            } label: {
                                Label(isPreviewing ? "Stop Preview" : "Preview Recording",
                                      systemImage: isPreviewing ? "stop.fill" : "play.fill")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Button(role: .destructive) {
                                deleteRecording()
                            } label: {
                                Label("Delete Recording", systemImage: "trash")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.red.opacity(0.12))
                                    .foregroundStyle(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            // Share the same take with siblings — one tap per
                            // child copies the file into their folder.
                            if !otherChildren.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Also save it for…")
                                        .font(.caption.bold())
                                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(otherChildren, id: \.self) { child in
                                                let isShared = sharedWith.contains(child)
                                                Button {
                                                    toggleShare(with: child)
                                                } label: {
                                                    HStack(spacing: 6) {
                                                        Image(systemName: isShared ? "checkmark.circle.fill" : "plus.circle")
                                                            .font(.caption)
                                                        Text(child)
                                                            .font(.caption.bold())
                                                    }
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        isShared
                                                        ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.85)
                                                        : AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                                                    )
                                                    .foregroundStyle(
                                                        isShared
                                                        ? .white
                                                        : AppTheme.primaryText(for: appSettings.isBedtimeMode)
                                                    )
                                                    .clipShape(Capsule())
                                                }
                                                .buttonStyle(.plain)
                                                .accessibilityLabel(
                                                    isShared
                                                    ? "Recording saved for \(child). Tap to remove."
                                                    : "Also save recording for \(child)"
                                                )
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Text("Recordings stay on this device only. Nothing is uploaded.")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .padding()
            }
            .background(AppTheme.background(for: appSettings.isBedtimeMode))
            .navigationTitle("Parent Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .onAppear {
            refreshHasRecording()
        }
        .onDisappear {
            // Tidy up so nothing keeps recording/playing after the sheet closes.
            if recorder.isRecording { recorder.stopRecording() }
            stopPreview()
        }
    }

    // MARK: - Actions

    private func refreshHasRecording() {
        hasRecording = recorder.hasRecording(storyID: story.id, profile: profile)
        sharedWith = Set(otherChildren.filter {
            recorder.hasRecording(storyID: story.id, profile: $0)
        })
    }

    /// Copies this child's recording to a sibling, or removes the sibling's
    /// copy if they already have it.
    private func toggleShare(with child: String) {
        if sharedWith.contains(child) {
            recorder.deleteRecording(storyID: story.id, profile: child)
        } else {
            recorder.copyRecording(storyID: story.id, from: profile, to: child)
        }
        refreshHasRecording()
    }

    private func beginRecording() {
        // Stop any story playback so it doesn't bleed into the recording.
        audioPlayerViewModel.stop()
        stopPreview()

        recorder.requestPermission { granted in
            guard granted else {
                permissionDenied = true
                return
            }
            permissionDenied = false
            recordingFailed = !recorder.startRecording(storyID: story.id, profile: profile)
        }
    }

    private func stopRecording() {
        recorder.stopRecording()
        refreshHasRecording()
    }

    private func deleteRecording() {
        stopPreview()
        recorder.deleteRecording(storyID: story.id, profile: profile)
        refreshHasRecording()
    }

    // MARK: - Preview playback (local to the sheet)

    private func startPreview() {
        guard let url = recorder.recordingURL(storyID: story.id, profile: profile),
              FileManager.default.fileExists(atPath: url.path) else { return }
        // Restore the playback category before previewing — recording may have
        // left the session in .playAndRecord.
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            previewPlayer = player
            isPreviewing = true
        } catch {
            print("[ParentVoice] Preview failed: \(error.localizedDescription)")
        }
    }

    private func stopPreview() {
        previewPlayer?.stop()
        previewPlayer = nil
        isPreviewing = false
    }
}
