import SwiftUI

// MARK: - Games
// A kid-friendly hub of small Bible games, all offline and procedural:
//   1. Treasure Match  — flip-card memory pairs using the story collectibles
//   2. Story Quiz      — gentle multiple-choice questions about the stories
//   3. Verse Practice  — the existing missing-word game on a random story
// No ads, no timers that pressure, no losing states that sting — every game
// ends in encouragement (COPPA-clean, bedtime-calm).

struct GamesView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var library: StoryLibraryViewModel

    /// A story with a memory verse for Verse Practice — re-rolled each visit.
    private var verseStory: Story? {
        library.stories.filter { $0.memoryVerse != nil }.randomElement()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
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
                }
                .padding(.top, 4)

                NavigationLink(destination: MemoryMatchGameView()) {
                    GameCard(
                        icon: "rectangle.grid.2x2.fill",
                        title: "Treasure Match",
                        subtitle: "Find the matching pairs of story treasures",
                        tint: .indigo
                    )
                }
                .buttonStyle(.plain)

                NavigationLink(destination: StoryQuizView()) {
                    GameCard(
                        icon: "questionmark.circle.fill",
                        title: "Story Quiz",
                        subtitle: "Do you remember the stories? Six little questions",
                        tint: .teal
                    )
                }
                .buttonStyle(.plain)

                if let story = verseStory {
                    NavigationLink(destination: MemoryVerseGameView(story: story)) {
                        GameCard(
                            icon: "text.book.closed.fill",
                            title: "Verse Practice",
                            subtitle: "Find the missing word in \"\(story.title)\"",
                            tint: .orange
                        )
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
}

// MARK: - Game Card

private struct GameCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(tint.opacity(0.22))
                    .frame(width: 54, height: 54)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(tint)
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

    @State private var cards: [MatchCard] = []
    @State private var firstFlipped: Int? = nil
    @State private var moves: Int = 0
    @State private var matchesFound: Int = 0
    @State private var checking = false

    private let pairCount = 6

    private var won: Bool { matchesFound == pairCount }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("\(moves) flips", systemImage: "hand.tap.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Spacer()
                if bestMoves > 0 {
                    Label("Best: \(bestMoves)", systemImage: "star.fill")
                        .font(.subheadline)
                        .foregroundStyle(.yellow)
                }
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3),
                      spacing: 10) {
                ForEach(cards.indices, id: \.self) { index in
                    MatchCardView(card: cards[index])
                        .onTapGesture { flip(index) }
                }
            }
            .padding(.horizontal)

            if won {
                VStack(spacing: 10) {
                    Text("🎉 You found them all!")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text(bestMoves == moves
                         ? "That's your best game yet — \(moves) flips!"
                         : "All \(pairCount) pairs in \(moves) flips. Wonderful!")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    Button {
                        startGame()
                    } label: {
                        Label("Play Again", systemImage: "arrow.clockwise")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding()
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
        let treasures = Collectible.all.shuffled().prefix(pairCount)
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
            // A match — leave both up, glow them
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 350_000_000)
                withAnimation(.spring(response: 0.35)) {
                    cards[first].isMatched = true
                    cards[index].isMatched = true
                    matchesFound += 1
                }
                checking = false
                if matchesFound == pairCount && (bestMoves == 0 || moves < bestMoves) {
                    bestMoves = moves
                }
            }
        } else {
            // No match — flip both back after a peek
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

    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(card.isFaceUp || card.isMatched
                      ? AppTheme.cardBackground(for: appSettings.isBedtimeMode)
                      : AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.8))

            if card.isFaceUp || card.isMatched {
                Text(card.emoji)
                    .font(.system(size: 36))
            } else {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(height: 86)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(card.isMatched ? Color.yellow.opacity(0.8) : .clear, lineWidth: 2)
        )
        .rotation3DEffect(.degrees(card.isFaceUp || card.isMatched ? 0 : 180),
                          axis: (x: 0, y: 1, z: 0))
        .accessibilityLabel(card.isFaceUp || card.isMatched ? card.emoji : "Hidden card")
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
        VStack(spacing: 18) {
            if finished {
                resultView
            } else if current < questions.count {
                questionView(questions[current])
            }
            Spacer()
        }
        .padding()
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Story Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if questions.isEmpty { startRound() } }
    }

    private func startRound() {
        questions = Array(QuizQuestion.bank.shuffled().prefix(questionsPerRound))
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

    private var resultView: some View {
        VStack(spacing: 14) {
            Text(score == questions.count ? "🌟" : "✨")
                .font(.system(size: 56))
            Text("You got \(score) of \(questions.count)!")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            Text(score == questions.count
                 ? "Every single one — amazing!"
                 : score >= questions.count / 2
                   ? "Wonderful remembering!"
                   : "Every story you hear makes you wiser. Try again?")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

            Button {
                startRound()
            } label: {
                Label("Play Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 40)
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
                finished = true
            } else {
                current += 1
                picked = nil
            }
        }
    }
}

// MARK: - Quiz question bank
// Hand-written, kid-level, tied to stories in the app. Keep answers
// unambiguous and the wrong choices gentle (no trick questions).

struct QuizQuestion {
    let prompt: String
    let choices: [String]
    let answerIndex: Int

    static let bank: [QuizQuestion] = [
        QuizQuestion(prompt: "Who built a big boat to keep the animals safe?",
                     choices: ["Noah", "Moses", "David"], answerIndex: 0),
        QuizQuestion(prompt: "What did God put in the sky as a promise to Noah?",
                     choices: ["A rainbow", "A cloud", "A kite"], answerIndex: 0),
        QuizQuestion(prompt: "Who was the shepherd boy who faced the giant Goliath?",
                     choices: ["Jonah", "David", "Peter"], answerIndex: 1),
        QuizQuestion(prompt: "What did David use to face Goliath?",
                     choices: ["A sword", "A sling and a stone", "A spear"], answerIndex: 1),
        QuizQuestion(prompt: "Where did Jonah end up when he ran from God?",
                     choices: ["In a big fish", "On a mountain", "In a castle"], answerIndex: 0),
        QuizQuestion(prompt: "Who spent a night with hungry lions and was kept safe?",
                     choices: ["Daniel", "Joseph", "Abraham"], answerIndex: 0),
        QuizQuestion(prompt: "What did Moses see burning that didn't burn up?",
                     choices: ["A bush", "A house", "A boat"], answerIndex: 0),
        QuizQuestion(prompt: "What happened to the sea when Moses lifted his staff?",
                     choices: ["It froze", "It split in two", "It turned gold"], answerIndex: 1),
        QuizQuestion(prompt: "Where was baby Jesus born?",
                     choices: ["A palace", "A stable", "A ship"], answerIndex: 1),
        QuizQuestion(prompt: "What led the wise men to baby Jesus?",
                     choices: ["A map", "A bright star", "A river"], answerIndex: 1),
        QuizQuestion(prompt: "What did Jesus do to the stormy sea?",
                     choices: ["He told it to be still", "He swam in it", "He sailed away"], answerIndex: 0),
        QuizQuestion(prompt: "How many loaves and fish fed the big crowd?",
                     choices: ["Five loaves and two fish", "Ten loaves", "A basket of apples"], answerIndex: 0),
        QuizQuestion(prompt: "Who climbed a tree to see Jesus?",
                     choices: ["Zacchaeus", "Goliath", "Samuel"], answerIndex: 0),
        QuizQuestion(prompt: "In Jesus' story, who stopped to help the hurt traveler?",
                     choices: ["A king", "The good Samaritan", "A fisherman"], answerIndex: 1),
        QuizQuestion(prompt: "What does the shepherd do when one sheep is lost?",
                     choices: ["He goes looking for it", "He waits at home", "He buys a new one"], answerIndex: 0),
        QuizQuestion(prompt: "How many days did God take to make the world?",
                     choices: ["Six days, then He rested", "One day", "A hundred days"], answerIndex: 0),
        QuizQuestion(prompt: "What fell down when Joshua's people marched and shouted?",
                     choices: ["The walls of Jericho", "A big tree", "The rain"], answerIndex: 0),
        QuizQuestion(prompt: "Whose colorful coat made his brothers jealous?",
                     choices: ["Joseph", "Daniel", "John"], answerIndex: 0),
        QuizQuestion(prompt: "Which brave queen spoke up to save her people?",
                     choices: ["Esther", "Mary", "Ruth"], answerIndex: 0),
        QuizQuestion(prompt: "What did God show Abraham to count?",
                     choices: ["The stars", "His sheep", "His coins"], answerIndex: 0),
        QuizQuestion(prompt: "Who walked on the water toward Jesus?",
                     choices: ["Peter", "Paul", "Pharaoh"], answerIndex: 0),
        QuizQuestion(prompt: "What did the little boy share so Jesus could feed everyone?",
                     choices: ["His lunch", "His coat", "His sandals"], answerIndex: 0),
        QuizQuestion(prompt: "How did God speak to Elijah on the mountain?",
                     choices: ["In a gentle whisper", "With thunder only", "Through a lion"], answerIndex: 0),
        QuizQuestion(prompt: "What is the very first thing God said when making the world?",
                     choices: ["\"Let there be light\"", "\"Make a boat\"", "\"Count the stars\""], answerIndex: 0),
    ]
}
