import Foundation
import AVFoundation

final class AudioPlaybackService: NSObject {
    private var player: AVAudioPlayer?
    var onPlaybackFinished: (() -> Void)?

    static func configureAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func loadAudio(named fileName: String) throws {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        let parts = fileName.split(separator: ".", maxSplits: 1).map(String.init)
        let name = parts.first ?? fileName
        let ext = parts.count > 1 ? parts[1] : "mp3"

        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            self.player = p
            return
        }

        let direct = Bundle.main.bundlePath + "/" + fileName
        if FileManager.default.fileExists(atPath: direct) {
            let p = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: direct))
            p.delegate = self
            p.prepareToPlay()
            self.player = p
            return
        }

        print("[Audio] NOT FOUND: \(fileName)")
        throw AudioPlaybackError.fileNotFound(fileName)
    }

    func loadAudio(from url: URL) throws {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        let p = try AVAudioPlayer(contentsOf: url)
        p.delegate = self
        p.prepareToPlay()
        self.player = p
    }

    @discardableResult
    func play() -> Bool {
        guard let player else {
            print("[Audio] play() - no player!")
            return false
        }
        return player.play()
    }

    func pause() { player?.pause() }

    func stop() {
        player?.stop()
        player?.currentTime = 0
    }

    func seek(by seconds: TimeInterval) {
        guard let player else { return }
        player.currentTime = max(0, min(player.duration, player.currentTime + seconds))
    }

    func seekTo(time: TimeInterval) {
        guard let player else { return }
        player.currentTime = max(0, min(player.duration, time))
    }

    func setVolume(_ volume: Float) {
        player?.volume = max(0, min(1, volume))
    }

    var isPlaying: Bool { player?.isPlaying ?? false }
    var currentTime: TimeInterval { player?.currentTime ?? 0 }
    var duration: TimeInterval { player?.duration ?? 0 }
}

enum AudioPlaybackError: LocalizedError {
    case fileNotFound(String)
    var errorDescription: String? {
        switch self { case .fileNotFound(let f): return "Audio file not found: \(f)" }
    }
}

extension AudioPlaybackService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onPlaybackFinished?()
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("[Audio] Decode error: \(error?.localizedDescription ?? "unknown")")
        onPlaybackFinished?()
    }
}
