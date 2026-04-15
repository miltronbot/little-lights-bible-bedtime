
import SwiftUI

// MARK: - Guided Breathing Exercise
// "Smell the flowers, blow out the candles" — a child-friendly 4-4-4-4 breathing exercise

struct BreathingExerciseView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var phase: BreathPhase = .ready
    @State private var circleScale: CGFloat = 0.5
    @State private var glowOpacity: Double = 0.0
    @State private var cycleCount: Int = 0
    @State private var isRunning: Bool = false
    @State private var phaseLabel: String = "Get Cozy"
    @State private var phaseEmoji: String = "🌙"

    private let totalCycles = 4
    private let inhaleDuration: Double = 4.0
    private let holdDuration: Double = 4.0
    private let exhaleDuration: Double = 4.0
    private let restDuration: Double = 2.0

    enum BreathPhase {
        case ready, inhale, hold, exhale, rest, done
    }

    var body: some View {
        ZStack {
            // Background
            AppTheme.background(for: appSettings.isBedtimeMode)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Breathing Exercise")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Let's calm our body and mind")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }

                Spacer()

                // Animated breathing circle
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            AppTheme.accent(for: appSettings.isBedtimeMode).opacity(glowOpacity * 0.3),
                            lineWidth: 3
                        )
                        .frame(width: 220, height: 220)
                        .scaleEffect(circleScale * 1.15)

                    // Main breathing circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.6),
                                    AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(circleScale)
                        .shadow(color: AppTheme.accent(for: appSettings.isBedtimeMode).opacity(glowOpacity * 0.5), radius: 30)

                    // Inner content
                    VStack(spacing: 8) {
                        Text(phaseEmoji)
                            .font(.system(size: 40))
                        Text(phaseLabel)
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }

                // Cycle progress dots
                HStack(spacing: 12) {
                    ForEach(0..<totalCycles, id: \.self) { index in
                        Circle()
                            .fill(index < cycleCount
                                  ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                  : AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2))
                            .frame(width: 10, height: 10)
                    }
                }

                Text("Breath \(min(cycleCount + 1, totalCycles)) of \(totalCycles)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                Spacer()

                // Action button
                if phase == .ready {
                    Button {
                        startBreathing()
                    } label: {
                        Label("Begin", systemImage: "wind")
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
                    .padding(.horizontal)
                } else if phase == .done {
                    VStack(spacing: 16) {
                        Text("Sweet dreams ahead")
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Text("Your body is calm and ready for sleep")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                        Button {
                            dismiss()
                        } label: {
                            Label("Continue to Story", systemImage: "book.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Button {
                        resetExercise()
                    } label: {
                        Text("Stop")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Breathing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func startBreathing() {
        isRunning = true
        cycleCount = 0
        runCycle()
    }

    private func runCycle() {
        guard cycleCount < totalCycles else {
            finishExercise()
            return
        }

        // Phase 1: Inhale — "Smell the flowers"
        phase = .inhale
        phaseLabel = "Smell the flowers"
        phaseEmoji = "🌸"
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            circleScale = 1.0
            glowOpacity = 1.0
        }

        // Phase 2: Hold — "Hold it gently"
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration) {
            guard isRunning else { return }
            phase = .hold
            phaseLabel = "Hold it gently"
            phaseEmoji = "✨"
        }

        // Phase 3: Exhale — "Blow out the candles"
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration + holdDuration) {
            guard isRunning else { return }
            phase = .exhale
            phaseLabel = "Blow out the candles"
            phaseEmoji = "🕯️"
            withAnimation(.easeInOut(duration: exhaleDuration)) {
                circleScale = 0.5
                glowOpacity = 0.2
            }
        }

        // Phase 4: Rest — brief pause between cycles
        DispatchQueue.main.asyncAfter(deadline: .now() + inhaleDuration + holdDuration + exhaleDuration) {
            guard isRunning else { return }
            cycleCount += 1
            phase = .rest
            phaseLabel = "Rest"
            phaseEmoji = "🌙"

            DispatchQueue.main.asyncAfter(deadline: .now() + restDuration) {
                guard isRunning else { return }
                runCycle()
            }
        }
    }

    private func finishExercise() {
        phase = .done
        phaseLabel = "All Done!"
        phaseEmoji = "⭐"
        withAnimation(.easeInOut(duration: 1.0)) {
            circleScale = 0.7
            glowOpacity = 0.5
        }
    }

    private func resetExercise() {
        isRunning = false
        phase = .ready
        phaseLabel = "Get Cozy"
        phaseEmoji = "🌙"
        cycleCount = 0
        withAnimation(.easeInOut(duration: 0.5)) {
            circleScale = 0.5
            glowOpacity = 0.0
        }
    }
}
