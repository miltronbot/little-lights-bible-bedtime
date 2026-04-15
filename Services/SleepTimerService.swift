
import Foundation
import Combine

@MainActor
final class SleepTimerService: ObservableObject {
    @Published private(set) var isActive: Bool = false
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var totalSeconds: Int = 0

    private var timerCancellable: AnyCancellable?
    var onTimerExpired: (() -> Void)?

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var remainingText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func start(minutes: Int) {
        stop()
        guard minutes > 0 else { return }

        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
        isActive = true

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.onTimerExpired?()
                    self.stop()
                }
            }
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
        isActive = false
        remainingSeconds = 0
        totalSeconds = 0
    }

    func addTime(minutes: Int) {
        guard isActive else { return }
        remainingSeconds += minutes * 60
        totalSeconds += minutes * 60
    }

    static let presetMinutes: [Int] = [15, 30, 45, 60]
}
