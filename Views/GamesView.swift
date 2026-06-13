import SwiftUI

// MARK: - Games
// A kid-friendly arcade of Bible games, all offline and procedural, all
// rooted in the app's stories. Games award shared "game stars"
// (GameStars.award → the hub counter). No ads, no pressure timers, no
// losing states that sting — every game ends in encouragement.
//
// Content banks (quiz questions, riddles, true/false, scrambles) live in
// Models/GameContent.swift; the five newer game views live in
// Views/Components/BibleGames.swift.

struct GamesView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var library: StoryLibraryViewModel

    @AppStorage(GameStars.key) private var totalStars: Int = 0

    /// A story with a memory verse for Verse Practice — re-rolled each visit.
    private var verseStory: Story? {
        library.stories.filter { MemoryVerseGame.isPlayable($0.memoryVerse) }.randomElement()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                // Header with the running star count
                HStack(spacing: 10) {
                    LumiMascotView(size: 32, message: nil)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bible Games")
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        Text("Play a little before lights out")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }
                    Spacer()
                    if totalStars > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                            Text("\(totalStars)")
                                .font(.subheadline.bold())
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(Color.yellow.opacity(0.18))
                        .foregroundStyle(.yellow)
                        .clipShape(Capsule())
                        .accessibilityLabel("\(totalStars) game stars earned")
                    }
                }
                .padding(.top, 4)

                sectionHeader("Guess & Remember")

                NavigationLink(destination: StoryQuizView()) {
                    GameCard(icon: "questionmark.circle.fill", title: "Story Quiz",
                             subtitle: "Six little questions about the stories", tint: .teal)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: WhoAmIGameView()) {
                    GameCard(icon: "person.fill.questionmark", title: "Who Am I?",
                             subtitle: "Three clues — guess sooner for more stars", tint: .purple)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: TrueFalseGameView()) {
                    GameCard(icon: "checkmark.seal.fill", title: "Lumi's True or False",
                             subtitle: "True or false — Lumi tells you the story behind each one", tint: .green)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: GuessTheStoryGameView()) {
                    GameCard(icon: "photo.fill", title: "Guess the Story",
                             subtitle: "A foggy picture clears — name it early for more stars", tint: .pink)
                }
                .buttonStyle(.plain)

                sectionHeader("Match & Order")

                NavigationLink(destination: MemoryMatchGameView()) {
                    GameCard(icon: "rectangle.grid.2x2.fill", title: "Treasure Match",
                             subtitle: "Find the matching pairs of story treasures", tint: .indigo)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: StoryScrambleGameView()) {
                    GameCard(icon: "list.number", title: "Story Scramble",
                             subtitle: "Put the story back in the right order", tint: .brown)
                }
                .buttonStyle(.plain)

                sectionHeader("Learn the Verse")

                NavigationLink(destination: VerseBuilderGameView()) {
                    GameCard(icon: "text.word.spacing", title: "Verse Builder",
                             subtitle: "Tap the words to build the verse", tint: .cyan)
                }
                .buttonStyle(.plain)

                if let story = verseStory {
                    NavigationLink(destination: MemoryVerseGameView(story: story)) {
                        GameCard(icon: "text.book.closed.fill", title: "Verse Practice",
                                 subtitle: "Find the missing word in \"\(story.title)\"", tint: .orange)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Games")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            .padding(.top, 6)
    }
}

// MARK: - Game Card

struct GameCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    @EnvironmentObject private var appSettings: AppSettings

    /// Bundled Midjourney artwork for this game, when the owner has added
    /// it to Assets.xcassets (same pipeline as story art). Named
    /// "game-<slug>" from the title; falls back to the SF-symbol tile so
    /// the hub never breaks while artwork is pending.
    private var artworkName: String {
        "game-" + title.lowercased()
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "?", with: "")
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " ", with: "-")
    }

    var body: some View {
        HStack(spacing: 14) {
            if let artwork = UIImage(named: artworkName) {
                Image(uiImage: artwork)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 58, height: 58)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(tint.opacity(0.22))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(tint)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Treasure Match (memory pairs)

struct MemoryMatchGameView: View {
    @EnvironmentObject private var appSettings: AppSettings

    @AppStorage("game.memoryMatch.bestMoves") private var bestMoves: Int = 0

    enum Difficulty: String, CaseIterable, Identifiable {
        case cozy = "Cozy"      // 6 pairs, 3×4
        case big  = "Big Kid"   // 8 pairs, 4×4

        var id: String { rawValue }
        var pairCount: Int { self == .cozy ? 6 : 8 }
        var columns: Int { self == .cozy ? 3 : 4 }
        var cardHeight: CGFloat { self == .cozy ? 86 : 74 }
    }

    @State private var difficulty: Difficulty = .cozy
    @State private var cards: [MatchCard] = []
    @State private var firstFlipped: Int? = nil
    @State private var moves: Int = 0
    @State private var matchesFound: Int = 0
    @State private var checking = false

    private var won: Bool { !cards.isEmpty && matchesFound == difficulty.pairCount }

    var body: some View {
        VStack(spacing: 14) {
            // Difficulty picker
            HStack(spacing: 8) {
                ForEach(Difficulty.allCases) { level in
                    Button {
                        difficulty = level
                        startGame()
                    } label: {
                        Text(level.rawValue)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(difficulty == level
                                        ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                        : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(difficulty == level ? .white : AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
                if bestMoves > 0 {
                    Label("Best: \(bestMoves)", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.horizontal)

            Label("\(moves) flips", systemImage: "hand.tap.fill")
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10),
                                     count: difficulty.columns),
                      spacing: 10) {
                ForEach(cards.indices, id: \.self) { index in
                    MatchCardView(card: cards[index], height: difficulty.cardHeight)
                        .onTapGesture { flip(index) }
                }
            }
            .padding(.horizontal)

            if won {
                GameResultCard(
                    emoji: "🎉",
                    headline: "You found them all!",
                    message: bestMoves == moves
                        ? "That's your best game yet — \(moves) flips!"
                        : "All \(difficulty.pairCount) pairs in \(moves) flips. Wonderful!",
                    buttonTitle: "Play Again"
                ) { startGame() }
                .padding(.horizontal)
                .transition(.scale.combined(with: .opacity))
            }

            Spacer()
        }
        .padding(.top)
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Treasure Match")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if cards.isEmpty { startGame() } }
    }

    private func startGame() {
        // Deck rotation: the next board never reuses the icons just played
        let treasures = GameDeck.draw(difficulty.pairCount, from: Collectible.all.count, key: "treasureMatch")
            .map { Collectible.all[$0] }
        var deck: [MatchCard] = []
        for t in treasures {
            deck.append(MatchCard(emoji: t.emoji, pairID: t.id))
            deck.append(MatchCard(emoji: t.emoji, pairID: t.id))
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            cards = deck.shuffled()
            firstFlipped = nil
            moves = 0
            matchesFound = 0
            checking = false
        }
    }

    private func flip(_ index: Int) {
        guard !checking,
              !cards[index].isFaceUp,
              !cards[index].isMatched else { return }

        withAnimation(.spring(response: 0.3)) {
            cards[index].isFaceUp = true
        }
        moves += 1

        guard let first = firstFlipped else {
            firstFlipped = index
            return
        }
        firstFlipped = nil
        checking = true

        if cards[first].pairID == cards[index].pairID {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 350_000_000)
                withAnimation(.spring(response: 0.35)) {
                    cards[first].isMatched = true
                    cards[index].isMatched = true
                    matchesFound += 1
                }
                checking = false
                if matchesFound == difficulty.pairCount {
                    if bestMoves == 0 || moves < bestMoves { bestMoves = moves }
                    // Tidy games earn more — perfect would be pairs×2 flips
                    let perfect = difficulty.pairCount * 2
                    GameStars.award(moves <= perfect + 4 ? 3 : moves <= perfect + 10 ? 2 : 1)
                }
            }
        } else {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 900_000_000)
                withAnimation(.spring(response: 0.35)) {
                    cards[first].isFaceUp = false
                    cards[index].isFaceUp = false
                }
                checking = false
            }
        }
    }
}

struct MatchCard: Identifiable {
    let id = UUID()
    let emoji: String
    let pairID: String
    var isFaceUp = false
    var isMatched = false
}

private struct MatchCardView: View {
    let card: MatchCard
    var height: CGFloat = 86

    @EnvironmentObject private var appSettings: AppSettings

    private var collectible: Collectible? {
        Collectible.all.first { $0.id == card.pairID }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(card.isFaceUp || card.isMatched
                      ? AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                      : AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.8))

            if card.isFaceUp || card.isMatched {
                if let collectible = collectible {
                    CollectibleIconView(collectible: collectible, size: height * 0.6)
                } else {
                    Text(card.emoji)
                        .font(.system(size: height * 0.42))
                }
            } else {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(card.isMatched ? Color.yellow.opacity(0.8) : .clear, lineWidth: 2)
        )
        .rotation3DEffect(.degrees(card.isFaceUp || card.isMatched ? 0 : 180),
                          axis: (x: 0, y: 1, z: 0))
        .accessibilityLabel(card.isFaceUp || card.isMatched
                            ? (collectible?.name ?? card.emoji)
                            : "Hidden card")
    }
}

// MARK: - Story Quiz

struct StoryQuizView: View {
    @EnvironmentObject private var appSettings: AppSettings

    @State private var questions: [QuizQuestion] = []
    @State private var current = 0
    @State private var score = 0
    @State private var picked: Int? = nil
    @State private var finished = false

    private let questionsPerRound = 6

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if finished {
                    GameResultCard(
                        emoji: score == questions.count ? "🌟" : "✨",
                        headline: "You got \(score) of \(questions.count)!",
                        message: score == questions.count
                            ? "Every single one — amazing!"
                            : score >= questions.count / 2
                              ? "Wonderful remembering!"
                              : "Every story you hear makes you wiser. Try again?",
                        buttonTitle: "Play Again"
                    ) { startRound() }
                    .padding(.top, 30)
                } else if current < questions.count {
                    questionView(questions[current])
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Story Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if questions.isEmpty { startRound() } }
    }

    private func startRound() {
        questions = GameDeck.draw(questionsPerRound, from: QuizQuestion.bank.count, key: "storyQuiz")
            .map { QuizQuestion.bank[$0] }
        current = 0
        score = 0
        picked = nil
        finished = false
    }

    @ViewBuilder
    private func questionView(_ q: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question \(current + 1) of \(questions.count)")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

            Text(q.prompt)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .fixedSize(horizontal: false, vertical: true)

            ForEach(q.choices.indices, id: \.self) { i in
                Button {
                    pick(i, for: q)
                } label: {
                    HStack {
                        Text(q.choices[i])
                            .font(.body.bold())
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if let picked {
                            if i == q.answerIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            } else if i == picked {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(choiceBackground(i, for: q))
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(picked != nil)
            }

            if picked != nil {
                HStack {
                    Text(picked == q.answerIndex ? "That's right! ⭐" : "Good try! The answer is \(q.choices[q.answerIndex]).")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    Spacer()
                    Button {
                        advance()
                    } label: {
                        Text(current + 1 == questions.count ? "Finish" : "Next")
                            .font(.headline)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .transition(.opacity)
            }
        }
    }

    private func choiceBackground(_ i: Int, for q: QuizQuestion) -> Color {
        guard let picked else {
            return AppTheme.cardBackground(for: appSettings.isBedtimeMode)
        }
        if i == q.answerIndex { return Color.green.opacity(0.25) }
        if i == picked { return Color.orange.opacity(0.22) }
        return AppTheme.cardBackground(for: appSettings.isBedtimeMode)
    }

    private func pick(_ i: Int, for q: QuizQuestion) {
        guard picked == nil else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            picked = i
            if i == q.answerIndex { score += 1 }
        }
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if current + 1 == questions.count {
                GameStars.award(max(1, score / 2))   // 6/6 → 3⭐, 4–5 → 2⭐, else 1⭐
                finished = true
            } else {
                current += 1
                picked = nil
            }
        }
    }
}
