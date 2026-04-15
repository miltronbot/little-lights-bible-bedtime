
import SwiftUI

struct AudioPlayerBar: View {
    @EnvironmentObject private var audioPlayerViewModel: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings

    let story: Story

    @State private var isScrubbing = false
    @State private var scrubValue: Double = 0

    private var isCurrentStory: Bool { audioPlayerViewModel.currentStoryID == story.id }

    private var isGenerating: Bool {
        audioPlayerViewModel.isGeneratingAudio && audioPlayerViewModel.currentStoryID == story.id
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                if isGenerating {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Generating voice...")
                            .font(.headline)
                    }
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                } else {
                    Text(isCurrentStory && audioPlayerViewModel.isPlaying ? "Now Playing" : "Narration")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                }
                Spacer()
                Text("\(isCurrentStory ? audioPlayerViewModel.currentTimeText : "0:00") / \(isCurrentStory ? audioPlayerViewModel.durationText : "–:––")")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            // Seek slider
            Slider(
                value: Binding(
                    get: {
                        isScrubbing ? scrubValue : (isCurrentStory ? audioPlayerViewModel.progress : 0)
                    },
                    set: { newValue in
                        scrubValue = newValue
                        isScrubbing = true
                    }
                ),
                in: 0...1,
                onEditingChanged: { editing in
                    if !editing {
                        let targetTime = scrubValue * audioPlayerViewModel.duration
                        audioPlayerViewModel.seekTo(time: targetTime)
                        isScrubbing = false
                    }
                }
            )
            .tint(AppTheme.accent(for: appSettings.isBedtimeMode))
            .disabled(!isCurrentStory || isGenerating)

            HStack(spacing: 16) {
                Button {
                    audioPlayerViewModel.skipBackward()
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .clipShape(Circle())
                }
                .disabled(!isCurrentStory || isGenerating)
                .accessibilityLabel("Skip backward 15 seconds")

                Button {
                    if !isGenerating {
                        audioPlayerViewModel.togglePlayback(for: story)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent(for: appSettings.isBedtimeMode))
                            .frame(width: 60, height: 60)
                        if isGenerating {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.2)
                        } else {
                            Image(systemName: isCurrentStory && audioPlayerViewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .accessibilityLabel(isGenerating ? "Generating audio" : (isCurrentStory && audioPlayerViewModel.isPlaying ? "Pause" : "Play"))

                Button {
                    audioPlayerViewModel.skipForward()
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title3)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .clipShape(Circle())
                }
                .disabled(!isCurrentStory || isGenerating)
                .accessibilityLabel("Skip forward 15 seconds")
            }

            // Voice label when ElevenLabs is active
            if isCurrentStory, let voice = ElevenLabsVoice.all.first(where: {
                $0.id == (UserDefaults.standard.string(forKey: "selectedVoiceID") ?? ElevenLabsVoice.defaultVoiceID)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "waveform.circle")
                        .font(.caption2)
                    Text("Voice: \(voice.name) · \(voice.description)")
                        .font(.caption2)
                }
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .animation(.easeInOut(duration: 0.2), value: isGenerating)
    }
}
