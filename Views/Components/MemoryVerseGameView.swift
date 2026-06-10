import SwiftUI

// MARK: - Memory Verse Game
// A gentle tap-the-missing-word game built from a story's memory verse.
// One word hides at a time; the child picks it from three big friendly
// buttons. Wrong answers get a kind "try again" — never a failure state.
// Finishing earns confetti and praise, nothing more: calm by design.

struct MemoryVerseGameView: View {
    let story: Story

    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    @State private var rounds: [GameRound] = []
    @State private var currentRound: Int = 0
    @State private var wrongPick: String? = nil        // choice that wiggles
    @State private var finished = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background(for: appSettings.isBedtimeMode)
                    .ignoresSafeArea()

                if finished {
                    finishedView
                } else if let round = rounds[safe: currentRound] {
                    gameView(round: round)
                } else {
                    // Verse too short to make a game from — shouldn't happen
                    // (the Practice button only shows for playable verses)
                    Text("This verse is ready to say together!")
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                }
            }
            .navigationTitle("Verse Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                rounds = MemoryVerseGame.makeRounds(verse: story.memoryVerse ?? "")
            }
        }
    }

    // MARK: Game screen

    private func gameView(round: GameRound) -> some View {
        VStack(spacing: 28) {
            Text("Which word is missing?")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            // The verse, with the current word hidden and solved words shown
            Text(displayVerse(round: round))
                .font(.system(size: 22, weight: .medium, design: .serif))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

            Text(round.reference)
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

            VStack(spacing: 14) {
                ForEach(round.choices, id: \.self) { choice in
                    Button {
                        pick(choice, round: round)
                    } label: {
                        Text(choice)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .opacity(wrongPick == choice ? 0.4 : 1.0)
                            .offset(x: wrongPick == choice ? -6 : 0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.4), value: wrongPick)
                    }
                    .disabled(wrongPick == choice)
                }
            }
            .padding(.horizontal)

            if wrongPick != nil {
                Text("Almost! Try another one 💛")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            // Round progress dots
            HStack(spacing: 8) {
                ForEach(0..<rounds.count, id: \.self) { i in
                    Circle()
                        .fill(i < currentRound
                            ? AppTheme.accent(for: appSettings.isBedtimeMode)
                            : AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.25))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.vertical)
    }

    // MARK: Finished screen

    private var finishedView: some View {
        ZStack {
            ConfettiView()
            VStack(spacing: 20) {
                Text("⭐")
                    .font(.system(size: 64))
                Text("You did it!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("You're learning God's Word by heart.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                Text(story.memoryVerse ?? "")
                    .font(.system(size: 19, weight: .medium, design: .serif))
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .padding()

                Button {
                    dismiss()
                } label: {
                    Text("Goodnight ✨")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
            }
            .padding()
        }
    }

    // MARK: Logic

    private func displayVerse(round: GameRound) -> String {
        var words = round.verseWords
        words[round.hiddenIndex] = "✨ ____ ✨"
        return words.joined(separator: " ")
    }

    private func pick(_ choice: String, round: GameRound) {
        guard choice == round.answer else {
            wrongPick = choice
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                wrongPick = nil
            }
            return
        }
        wrongPick = nil
        if currentRound + 1 < rounds.count {
            currentRound += 1
        } else {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                finished = true
            }
        }
    }
}

// MARK: - Round model + builder

struct GameRound {
    let verseWords: [String]    // display words (with punctuation)
    let hiddenIndex: Int        // which word is hidden this round
    let answer: String          // the choice text that is correct
    let choices: [String]       // shuffled: answer + 2 decoys
    let reference: String
}

enum MemoryVerseGame {

    static let decoyPool = [
        "love", "light", "heart", "peace", "hope", "brave",
        "gentle", "always", "good", "strong", "faithful", "trust",
        "shepherd", "morning", "little", "together",
    ]

    private static let stopwords: Set<String> = [
        "the", "and", "that", "with", "will", "this", "from", "have",
        "your", "you", "for", "who", "his", "her", "them", "they",
        "are", "was", "were", "been", "more", "over", "unto", "is",
        "in", "of", "to", "a", "be", "me", "my", "it", "on", "he", "she",
    ]

    /// True when a verse has enough substantial words to play with.
    static func isPlayable(_ verse: String?) -> Bool {
        guard let verse, !verse.isEmpty else { return false }
        return !candidateIndices(for: verseWords(of: verse)).isEmpty
    }

    static func makeRounds(verse: String) -> [GameRound] {
        let words = verseWords(of: verse)
        let reference = referencePart(of: verse)
        let candidates = candidateIndices(for: words).shuffled()
        let picked = Array(candidates.prefix(3))

        return picked.map { index in
            let answer = cleaned(words[index])
            let decoys = decoyPool.filter { $0.caseInsensitiveCompare(answer) != .orderedSame }.shuffled()
            let choices = ([answer] + Array(decoys.prefix(2))).shuffled()
            return GameRound(
                verseWords: words,
                hiddenIndex: index,
                answer: answer,
                choices: choices,
                reference: reference
            )
        }
    }

    /// Words of the quoted verse text (reference stripped).
    private static func verseWords(of verse: String) -> [String] {
        let versePart = verse.components(separatedBy: " — ").first ?? verse
        return versePart
            .replacingOccurrences(of: "\u{201C}", with: "")
            .replacingOccurrences(of: "\u{201D}", with: "")
            .replacingOccurrences(of: "\"", with: "")
            .split(separator: " ")
            .map(String.init)
    }

    private static func referencePart(of verse: String) -> String {
        let parts = verse.components(separatedBy: " — ")
        return parts.count > 1 ? "— " + parts[1] : ""
    }

    /// Indices of words substantial enough to hide.
    private static func candidateIndices(for words: [String]) -> [Int] {
        words.indices.filter { i in
            let w = cleaned(words[i]).lowercased()
            return w.count >= 4 && !stopwords.contains(w) && w.allSatisfy(\.isLetter)
        }
    }

    /// Strips punctuation for use as a tappable choice.
    private static func cleaned(_ word: String) -> String {
        word.trimmingCharacters(in: CharacterSet.letters.inverted)
    }
}

// MARK: - Safe index helper

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
