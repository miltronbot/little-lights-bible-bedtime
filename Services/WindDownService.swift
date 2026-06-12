import Foundation

// MARK: - Wind-Down auto mode
// When the app is opened at/after the family's set bedtime, gently dim into
// bedtime mode and stage "Tonight's Story" for a one-tap start. We never
// auto-play audio (COPPA / no surprise sound) — we only line the story up.
//
// iOS will not wake a suspended app at an arbitrary clock time, so this can
// only fire on the next foreground (scenePhase == .active). The day-stamp
// guard ensures it fires at most once per night, mirroring GoalsTracker's
// "yyyy-MM-dd" string-compare pattern.

enum WindDownService {

    /// Today's day-stamp in the same "yyyy-MM-dd" format GoalsTracker uses.
    static func dayStamp(for date: Date = Date()) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    /// Pure, testable decision: should wind-down fire right now?
    ///
    /// Fires when ALL hold:
    /// - the current time of day is at/after the set bedtime (hour:minute), and
    /// - it has not already fired today (lastFiredDayStamp != today's stamp).
    ///
    /// - Parameters:
    ///   - now: the current moment (injectable for tests).
    ///   - lastFiredDayStamp: the stored "windDownLastFired" stamp.
    ///   - hour: bedtime hour (0–23).
    ///   - minute: bedtime minute (0–59).
    static func shouldTrigger(now: Date,
                              lastFiredDayStamp: String,
                              hour: Int,
                              minute: Int) -> Bool {
        let today = dayStamp(for: now)
        // Already fired tonight — do nothing.
        guard lastFiredDayStamp != today else { return false }

        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute], from: now)
        let nowMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        let bedtimeMinutes = hour * 60 + minute
        return nowMinutes >= bedtimeMinutes
    }
}
