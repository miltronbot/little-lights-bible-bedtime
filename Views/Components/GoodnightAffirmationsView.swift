
import SwiftUI

// MARK: - Goodnight Affirmations
// Positive faith-based affirmations shown after completing a bedtime prayer

struct GoodnightAffirmationsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex: Int = 0
    @State private var textOpacity: Double = 0.0
    @State private var starScale: CGFloat = 0.3
    @State private var showDoneButton: Bool = false

    private var affirmations: [String] {
        let name = appSettings.activeChildName.isEmpty ? "You" : appSettings.activeChildName
        return [
            "\(name), you are loved by God",
            "\(name), you are brave and strong",
            "God is always with \(appSettings.activeChildName.isEmpty ? "you" : appSettings.activeChildName)",
            "\(name), you are kind and good",
            "Tomorrow is a new adventure, \(name)",
            "\(name), you are safe in God's hands",
            "\(appSettings.activeChildName.isEmpty ? "Your" : "\(appSettings.activeChildName)'s") family loves \(appSettings.activeChildName.isEmpty ? "you" : appSettings.activeChildName) so much",
            "\(name) can do anything with God's help",
        ]
    }

    // Pick 3 random affirmations for tonight
    private var tonightsAffirmations: [String] {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        var selected: [String] = []
        for i in 0..<3 {
            let index = (dayOfYear + i * 3) % affirmations.count
            selected.append(affirmations[index])
        }
        return selected
    }

    var body: some View {
        ZStack {
            // Dark calming background
            Color(red: 0.04, green: 0.04, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Glowing star
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.yellow.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(starScale)

                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.yellow)
                        .scaleEffect(starScale)
                }

                // Affirmation text
                if currentIndex < tonightsAffirmations.count {
                    Text(tonightsAffirmations[currentIndex])
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(textOpacity)
                        .padding(.horizontal, 32)
                        .id(currentIndex) // Force view rebuild for animation
                }

                // Progress dots
                HStack(spacing: 10) {
                    ForEach(0..<tonightsAffirmations.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentIndex ? Color.yellow : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                if showDoneButton {
                    VStack(spacing: 16) {
                        Text(appSettings.activeChildName.isEmpty ? "Sweet Dreams" : "Sweet Dreams, \(appSettings.activeChildName)")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.6))

                        Button {
                            dismiss()
                        } label: {
                            Label("Goodnight", systemImage: "moon.fill")
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
                        .padding(.horizontal, 32)
                    }
                } else {
                    Button {
                        advanceAffirmation()
                    } label: {
                        Text("Next")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding()
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            showCurrentAffirmation()
        }
    }

    private func showCurrentAffirmation() {
        textOpacity = 0
        starScale = 0.3

        withAnimation(.easeOut(duration: 1.0)) {
            textOpacity = 1.0
            starScale = 1.0
        }
    }

    private func advanceAffirmation() {
        withAnimation(.easeIn(duration: 0.3)) {
            textOpacity = 0
            starScale = 0.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if currentIndex < tonightsAffirmations.count - 1 {
                currentIndex += 1
                showCurrentAffirmation()
            } else {
                withAnimation(.easeOut(duration: 0.5)) {
                    showDoneButton = true
                    starScale = 1.2
                    textOpacity = 0
                }
            }
        }
    }
}
