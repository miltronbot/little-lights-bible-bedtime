
import SwiftUI

// MARK: - Discussion Questions
// 2-3 parent-child bonding questions per story, generated from story themes

struct DiscussionQuestionsView: View {
    let story: Story
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Talk Together", systemImage: "bubble.left.and.bubble.right.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            Text("Questions to explore with your child")
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

            VStack(alignment: .leading, spacing: 14) {
                ForEach(Array(questionsForStory.enumerated()), id: \.offset) { index, question in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.15))
                                .frame(width: 28, height: 28)
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                        }

                        Text(question)
                            .font(.system(size: appSettings.fontSize))
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // Generate discussion questions based on story category and theme
    private var questionsForStory: [String] {
        let categoryQuestions = questionBank[story.category] ?? defaultQuestions
        // Use story ID hash to deterministically pick questions
        let hash = abs(story.id.hashValue)
        var selected: [String] = []
        for i in 0..<min(3, categoryQuestions.count) {
            let index = (hash + i * 7) % categoryQuestions.count
            if !selected.contains(categoryQuestions[index]) {
                selected.append(categoryQuestions[index])
            }
        }
        // Ensure we have at least 2 questions
        while selected.count < 2, selected.count < defaultQuestions.count {
            selected.append(defaultQuestions[selected.count])
        }
        return selected
    }

    private let questionBank: [StoryCategory: [String]] = [
        .trust: [
            "What does it mean to trust God, even when things are hard?",
            "Can you think of a time when you had to trust someone?",
            "How did the person in the story show they trusted God?",
            "What helps you feel safe and trusting?",
            "If you were in this story, what would you have done?",
        ],
        .courage: [
            "What made the person in this story brave?",
            "When is a time you felt really brave?",
            "How can God help us when we feel scared?",
            "What does it mean to be courageous?",
            "Who is someone brave that you look up to?",
        ],
        .peace: [
            "What makes you feel peaceful inside?",
            "How did God bring peace in this story?",
            "What can you do when you feel worried or upset?",
            "Where is your favorite calm and quiet place?",
            "How can we be peacemakers with our friends?",
        ],
        .love: [
            "How did the people in this story show love?",
            "What are some ways you show love to your family?",
            "How does God show us His love?",
            "Who is someone you love very much?",
            "What does it feel like to be loved?",
        ],
        .hope: [
            "What does hope mean to you?",
            "How did hope help the person in this story?",
            "What is something you are hoping for?",
            "How does God give us hope?",
            "What makes you feel hopeful about tomorrow?",
        ],
        .prayer: [
            "What is your favorite thing to pray about?",
            "How did prayer help in this story?",
            "When do you like to talk to God?",
            "What would you like to say to God right now?",
            "How does it feel when you pray?",
        ],
        .kindness: [
            "How was kindness shown in this story?",
            "What is the nicest thing someone did for you today?",
            "How can you be kind to someone tomorrow?",
            "Why does being kind make us feel good?",
            "What is a way to show kindness to someone new?",
        ],
    ]

    private let defaultQuestions = [
        "What was your favorite part of the story?",
        "What did you learn from this story?",
        "How does this story make you feel?",
    ]
}
