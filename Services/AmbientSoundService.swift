
import Foundation
import AVFoundation

enum AmbientSound: String, CaseIterable, Identifiable {
    case none = "none"
    case rain = "rain"
    case ocean = "ocean"
    case crickets = "crickets"
    case fireplace = "fireplace"
    case whiteNoise = "white_noise"
    case lullaby = "lullaby"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .rain: return "Gentle Rain"
        case .ocean: return "Ocean Waves"
        case .crickets: return "Night Crickets"
        case .fireplace: return "Cozy Fireplace"
        case .whiteNoise: return "White Noise"
        case .lullaby: return "Soft Lullaby"
        }
    }

    var icon: String {
        switch self {
        case .none: return "speaker.slash.fill"
        case .rain: return "cloud.rain.fill"
        case .ocean: return "water.waves"
        case .crickets: return "leaf.fill"
        case .fireplace: return "flame.fill"
        case .whiteNoise: return "waveform"
        case .lullaby: return "music.note"
        }
    }
}

final class AmbientSoundService: NSObject {
    private var player: AVAudioPlayer?
    private(set) var currentSound: AmbientSound = .none
    private(set) var volume: Float = 0.3

    func play(sound: AmbientSound, volume: Float = 0.3) {
        stop()
        guard sound != .none else { return }

        let fileName = sound.rawValue
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            // Ambient sound file not found — generate procedural audio
            generateProceduralAudio(for: sound, volume: volume)
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop forever
            player?.volume = volume
            player?.prepareToPlay()
            player?.play()
            currentSound = sound
            self.volume = volume
        } catch {
            #if DEBUG
            print("Failed to play ambient sound: \(error)")
            #endif
        }
    }

    func stop() {
        player?.stop()
        player = nil
        currentSound = .none
    }

    func setVolume(_ volume: Float) {
        self.volume = volume
        player?.volume = volume
    }

    func fadeOut(duration: TimeInterval = 3.0) {
        guard let player else { return }
        let steps = 30
        let interval = duration / Double(steps)
        let initialVolume = player.volume
        let volumeStep = initialVolume / Float(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) { [weak self] in
                guard let self, let player = self.player else { return }
                player.volume = max(0, initialVolume - (volumeStep * Float(i + 1)))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.stop()
        }
    }

    // Fallback when MP3 ambient files aren't bundled.
    // Does NOT update currentSound so callers know no audio is actually playing.
    private func generateProceduralAudio(for sound: AmbientSound, volume: Float) {
        // Ambient sound MP3 files are not bundled — cannot play audio.
        // currentSound remains .none to accurately reflect playback state.
    }
}
