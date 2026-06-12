import SwiftUI

// MARK: - Bible Games (Games tab)
// Five small games, all offline, all rooted in the app's stories, all
// ending in encouragement. Stars earned here feed the hub's total via
// GameStars.award (see GameContent.swift for all the content banks).

// MARK: - Who Am I? (character riddles)

struct WhoAmIGameView: View {
    @EnvironmentObject private var appSettings: AppSettings

    private let riddlesPerRound = 5

    @State private var riddles: [WhoAmIRiddle] = []
    @State private var current = 0
    @State private var cluesShown = 1
    @State private var picked: Int? = nil
    @State private var starsEarned = 0
    @State private var finished = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if finished {
                    GameResultCard(
                        emoji: "🕵️",
                        headline: "You earned \(starsEarned) stars!",
                        message: "Fewer clues, more stars — you really know these stories.",
                        buttonTitle: "Play Again"
                    ) { startRound() }
                } else if current < riddles.count {
                    riddleView(riddles[current])
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Who Am I?")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if riddles.isEmpty { startRound() } }
    }

    private func startRound() {
        riddles = GameDeck.draw(riddlesPerRound, from: WhoAmIRiddle.bank.count, key: "whoAmI")
            .map { WhoAmIRiddle.bank[$0] }
        current = 0
        cluesShown = 1
        picked = nil
        starsEarned = 0
        finished = false
    }

    @ViewBuilder
    private func riddleView(_ riddle: WhoAmIRiddle) -> some View {
        Text("Riddle \(current + 1) of \(riddles.count)")
            .font(.caption.bold())
            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

        // Clues reveal one at a time — guessing early earns more stars
        ForEach(0..<cluesShown, id: \.self) { i in
            HStack(alignment: .top, spacing: 10) {
                Text("💡")
                Text(riddle.clues[i])
                    .font(.body.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }

        if picked == nil && cluesShown < riddle.clues.count {
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { cluesShown += 1 }
            } label: {
                Label("Another clue, please!", systemImage: "lightbulb")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.18))
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }

        Text("Who am I?")
            .font(.headline)
            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            .padding(.top, 4)

        ForEach(riddle.choices.indices, id: \.self) { i in
            Button {
                pick(i, riddle: riddle)
            } label: {
                HStack {
                    Text(riddle.choices[i]).font(.body.bold())
                    Spacer()
                    if let picked {
                        if i == riddle.answerIndex {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        } else if i == picked {
                            Image(systemName: "xmark.circle.fill").foregroundStyle(.orange)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(picked != nil && i == riddle.answerIndex
                            ? Color.green.opacity(0.25)
                            : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .disabled(picked != nil)
        }

        if let picked {
            let starsForThis = picked == riddle.answerIndex ? max(1, 4 - cluesShown) : 0
            HStack {
                Text(picked == riddle.answerIndex
                     ? "Yes! \(String(repeating: "⭐", count: starsForThis))"
                     : "It was \(riddle.choices[riddle.answerIndex])! You'll get the next one.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                Spacer()
                Button {
                    advance()
                } label: {
                    Text(current + 1 == riddles.count ? "Finish" : "Next")
                        .font(.headline)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 10)
                        .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func pick(_ i: Int, riddle: WhoAmIRiddle) {
        guard picked == nil else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            picked = i
            if i == riddle.answerIndex {
                starsEarned += max(1, 4 - cluesShown)   // clue 1 → 3⭐, clue 2 → 2⭐, clue 3 → 1⭐
            }
        }
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if current + 1 == riddles.count {
                GameStars.award(starsEarned)
                finished = true
            } else {
                current += 1
                cluesShown = 1
                picked = nil
            }
        }
    }
}

// MARK: - Lumi's True or False

struct TrueFalseGameView: View {
    @EnvironmentObject private var appSettings: AppSettings

    // 6 per round x 300-item bank = 50 fully distinct rounds per pass
    private let itemsPerRound = 6

    @State private var items: [TrueFalseItem] = []
    @State private var current = 0
    @State private var score = 0
    @State private var answered: Bool? = nil   // the player's answer
    @State private var finished = false

    var body: some View {
        VStack(spacing: 18) {
            if finished {
                GameResultCard(
                    emoji: score == items.count ? "🌟" : "🐝",
                    headline: "You got \(score) of \(items.count)!",
                    message: score == items.count
                        ? "A perfect round — Lumi is doing happy loops!"
                        : "Lumi loves playing with you. Another round?",
                    buttonTitle: "Play Again"
                ) { startRound() }
                .padding(.top, 30)
            } else if current < items.count {
                itemView(items[current])
            }
            Spacer()
        }
        .padding()
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Lumi's True or False")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if items.isEmpty { startRound() } }
    }

    private func startRound() {
        items = GameDeck.draw(itemsPerRound, from: TrueFalseItem.bank.count, key: "trueFalse")
            .map { TrueFalseItem.bank[$0] }
        current = 0
        score = 0
        answered = nil
        finished = false
    }

    @ViewBuilder
    private func itemView(_ item: TrueFalseItem) -> some View {
        Text("\(current + 1) of \(items.count)")
            .font(.caption.bold())
            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

        HStack(alignment: .top, spacing: 10) {
            LumiMascotView(size: 34, message: nil)
            Text(item.statement)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 16))

        HStack(spacing: 12) {
            answerButton(label: "True", value: true, item: item, tint: .green)
            answerButton(label: "False", value: false, item: item, tint: .orange)
        }

        if let answered {
            VStack(alignment: .leading, spacing: 10) {
                Text(answered == item.isTrue ? "That's right! ⭐" : "Good try!")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text(item.note)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    advance()
                } label: {
                    Text(current + 1 == items.count ? "Finish" : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode).opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .transition(.opacity)
        }
    }

    private func answerButton(label: String, value: Bool, item: TrueFalseItem, tint: Color) -> some View {
        Button {
            guard answered == nil else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                answered = value
                if value == item.isTrue { score += 1 }
            }
        } label: {
            Text(label)
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(buttonBackground(value: value, item: item, tint: tint))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .disabled(answered != nil)
    }

    private func buttonBackground(value: Bool, item: TrueFalseItem, tint: Color) -> Color {
        guard answered != nil else { return tint.opacity(0.75) }
        return value == item.isTrue ? Color.green : Color.gray.opacity(0.4)
    }

    private func advance() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if current + 1 == items.count {
                GameStars.award(score >= items.count - 1 ? 3 : score >= items.count * 2 / 3 ? 2 : 1)
                finished = true
            } else {
                current += 1
                answered = nil
            }
        }
    }
}

// MARK: - Story Scramble (put the story in order)

struct StoryScrambleGameView: View {
    @EnvironmentObject private var appSettings: AppSettings

    @State private var story: ScrambleStory = ScrambleStory.bank[0]
    @State private var shuffledSteps: [String] = []
    @State private var placedCount = 0
    @State private var mistakes = 0
    @State private var wiggling: String? = nil
    @State private var started = false

    private var done: Bool { placedCount == story.steps.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(story.title)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("Tap the parts of the story in the right order!")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                // The story so far — fills in as you get them right
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<story.steps.count, id: \.self) { i in
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(i < placedCount
                                          ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                          : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                                    .frame(width: 28, height: 28)
                                Text("\(i + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(i < placedCount ? .white : AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            }
                            Text(i < placedCount ? story.steps[i] : "…")
                                .font(.subheadline.bold())
                                .foregroundStyle(i < placedCount
                                                 ? AppTheme.primaryText(for: appSettings.isBedtimeMode)
                                                 : AppTheme.secondaryText(for: appSettings.isBedtimeMode).opacity(0.5))
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(10)
                        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode).opacity(i < placedCount ? 1 : 0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                if done {
                    GameResultCard(
                        emoji: "📖",
                        headline: mistakes == 0 ? "Perfect order! ⭐⭐⭐" : "You did it! \(String(repeating: "⭐", count: starCount))",
                        message: mistakes == 0
                            ? "You know this story by heart."
                            : "The story is all in order — beautifully done.",
                        buttonTitle: "Another Story"
                    ) { startRound() }
                } else {
                    Text("Which part comes next?")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .padding(.top, 6)

                    ForEach(shuffledSteps.filter { step in
                        !story.steps.prefix(placedCount).contains(step)
                    }, id: \.self) { step in
                        Button {
                            tap(step)
                        } label: {
                            Text(step)
                                .font(.subheadline.bold())
                                .multilineTextAlignment(.leading)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.18))
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .offset(x: wiggling == step ? -6 : 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Story Scramble")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if !started { startRound(); started = true } }
    }

    private var starCount: Int { mistakes == 0 ? 3 : mistakes <= 2 ? 2 : 1 }

    private func startRound() {
        let drawn = GameDeck.draw(1, from: ScrambleStory.bank.count, key: "storyScramble")
        story = drawn.first.map { ScrambleStory.bank[$0] } ?? ScrambleStory.bank[0]
        shuffledSteps = story.steps.shuffled()
        placedCount = 0
        mistakes = 0
        wiggling = nil
    }

    private func tap(_ step: String) {
        if step == story.steps[placedCount] {
            withAnimation(.spring(response: 0.35)) {
                placedCount += 1
            }
            if placedCount == story.steps.count {
                GameStars.award(starCount)
            }
        } else {
            mistakes += 1
            withAnimation(.spring(response: 0.15)) { wiggling = step }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 180_000_000)
                withAnimation(.spring(response: 0.2)) { wiggling = nil }
            }
        }
    }
}

// MARK: - Guess the Story (artwork reveal)

struct GuessTheStoryGameView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var library: StoryLibraryViewModel

    @State private var story: Story? = nil
    @State private var choices: [String] = []
    @State private var blurStage = 0          // 0 = very blurry … 2 = almost clear
    @State private var picked: String? = nil

    private let blurLevels: [CGFloat] = [26, 12, 4]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let story {
                    Text("Whose story is this?")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    // The artwork, behind fog that can be cleared
                    Group {
                        if let ui = UIImage(named: story.id) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                        } else {
                            StoryArtworkView(story: story, cornerRadius: 18)
                        }
                    }
                    .frame(height: 230)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .blur(radius: picked == nil ? blurLevels[blurStage] : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .animation(.easeInOut(duration: 0.5), value: blurStage)
                    .animation(.easeInOut(duration: 0.5), value: picked)

                    if picked == nil && blurStage < blurLevels.count - 1 {
                        Button {
                            blurStage += 1
                        } label: {
                            Label("Make it clearer", systemImage: "eye")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.18))
                                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(choices, id: \.self) { title in
                        Button {
                            pick(title)
                        } label: {
                            HStack {
                                Text(title).font(.body.bold())
                                Spacer()
                                if picked != nil {
                                    if title == story.title {
                                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                    } else if title == picked {
                                        Image(systemName: "xmark.circle.fill").foregroundStyle(.orange)
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(picked != nil && title == story.title
                                        ? Color.green.opacity(0.25)
                                        : AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(picked != nil)
                    }

                    if let picked {
                        VStack(spacing: 10) {
                            Text(picked == story.title
                                 ? "Yes — \(story.title)! \(String(repeating: "⭐", count: 3 - blurStage))"
                                 : "It was \(story.title)! Now you'll know its picture.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            Button {
                                startRound()
                            } label: {
                                Label("Next Picture", systemImage: "photo.on.rectangle")
                                    .font(.headline)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 12)
                                    .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Guess the Story")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if story == nil { startRound() } }
    }

    private func startRound() {
        // Stable order + deck rotation: all 50 pictures come up before any repeat
        let pool = library.stories.sorted { $0.id < $1.id }
        guard let idx = GameDeck.draw(1, from: pool.count, key: "guessTheStory").first else { return }
        let next = pool[idx]
        story = next
        // Build decoys from distinct titles — never loop on randomElement,
        // which would spin forever if the library had fewer than 4 stories
        let decoys = Array(Set(library.stories.map(\.title)))
            .filter { $0 != next.title }
            .shuffled()
            .prefix(3)
        choices = ([next.title] + decoys).shuffled()
        blurStage = 0
        picked = nil
    }

    private func pick(_ title: String) {
        guard picked == nil, let story else { return }
        withAnimation(.easeInOut(duration: 0.3)) { picked = title }
        if title == story.title {
            GameStars.award(3 - blurStage)   // blurrier guess → more stars
        }
    }
}

// MARK: - Verse Builder (arrange the verse words)

struct VerseBuilderGameView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var library: StoryLibraryViewModel

    @State private var storyTitle = ""
    @State private var reference = ""
    @State private var words: [String] = []        // correct order
    @State private var pool: [IndexedWord] = []    // shuffled, tappable
    @State private var placedCount = 0
    @State private var mistakes = 0
    @State private var wiggling: Int? = nil
    @State private var started = false

    struct IndexedWord: Identifiable {
        let id: Int        // position in the correct order
        let text: String
    }

    private var done: Bool { !words.isEmpty && placedCount == words.count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Put the verse together!")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Text("From \"\(storyTitle)\" — tap the words in order.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                // The verse being built
                Text(builtLine)
                    .font(.system(size: appSettings.fontSize + 2, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    .frame(maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
                    .padding()
                    .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                if done {
                    Text("— \(reference)")
                        .font(.subheadline.italic())
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                    GameResultCard(
                        emoji: "📜",
                        headline: mistakes == 0 ? "Word-perfect! ⭐⭐⭐" : "Verse complete! \(String(repeating: "⭐", count: starCount))",
                        message: "Say it out loud once — learning by heart, one word at a time.",
                        buttonTitle: "Another Verse"
                    ) { startRound() }
                } else {
                    // Word chips, shuffled — placed chips leave the pool
                    FlowingChips(items: pool) { word in
                        Button {
                            tap(word)
                        } label: {
                            Text(word.text)
                                .font(.subheadline.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.2))
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                .clipShape(Capsule())
                                .offset(x: wiggling == word.id ? -6 : 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Verse Builder")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { if !started { startRound(); started = true } }
    }

    private var builtLine: String {
        words.prefix(placedCount).joined(separator: " ") + (done ? "" : " …")
    }

    private var starCount: Int { mistakes == 0 ? 3 : mistakes <= 2 ? 2 : 1 }

    private func startRound() {
        // Curated chip-friendly verses — one per story, dealt so all 50
        // come up before any repeat
        guard let idx = GameDeck.draw(1, from: BuilderVerse.bank.count, key: "verseBuilder").first
        else { return }
        let verse = BuilderVerse.bank[idx]
        storyTitle = verse.storyTitle
        reference = verse.reference
        words = verse.text.split(separator: " ").map(String.init)
        pool = words.enumerated().map { IndexedWord(id: $0.offset, text: $0.element) }.shuffled()
        placedCount = 0
        mistakes = 0
        wiggling = nil
    }

    private func tap(_ word: IndexedWord) {
        // A tap can land during the completion transition — never index past
        // the end of the verse.
        guard placedCount < words.count else { return }
        // Match by TEXT, not chip identity — verses repeat little words like
        // "the", and any chip with the right word must count.
        if word.text == words[placedCount] {
            withAnimation(.spring(response: 0.3)) {
                pool.removeAll { $0.id == word.id }
                placedCount += 1
            }
            if placedCount == words.count {
                GameStars.award(starCount)
            }
        } else {
            mistakes += 1
            withAnimation(.spring(response: 0.15)) { wiggling = word.id }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 180_000_000)
                withAnimation(.spring(response: 0.2)) { wiggling = nil }
            }
        }
    }
}

/// A simple wrapping chip layout (adaptive grid keeps it dependency-free).
private struct FlowingChips<Content: View>: View {
    let items: [VerseBuilderGameView.IndexedWord]
    @ViewBuilder let content: (VerseBuilderGameView.IndexedWord) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], spacing: 8) {
            ForEach(items) { content($0) }
        }
    }
}

// MARK: - Shared result card

struct GameResultCard: View {
    let emoji: String
    let headline: String
    let message: String
    let buttonTitle: String
    let onPlayAgain: () -> Void

    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 12) {
            Text(emoji).font(.system(size: 52))
            Text(headline)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            Button(action: onPlayAgain) {
                Label(buttonTitle, systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal)
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
