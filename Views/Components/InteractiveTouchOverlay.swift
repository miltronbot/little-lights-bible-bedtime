import SwiftUI

// MARK: - TouchElement Model
struct TouchElement: Identifiable {
    let id = UUID()
    let emoji: String
    let xPercent: CGFloat
    let yPercent: CGFloat
    let tapMessage: String
}

// MARK: - TouchBubble Popup View
struct TouchBubble: View {
    let message: String
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: 0) {
            Text(message)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .background(Color.indigo)
        .cornerRadius(12)
        .scaleEffect(isVisible ? 1.0 : 0.1)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}

// MARK: - InteractiveTouchOverlay View
struct InteractiveTouchOverlay: View {
    let elements: [TouchElement]
    @State private var activeBubble: TouchElement?
    @State private var dismissTimer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Render each touch element
                ForEach(elements) { element in
                    VStack(spacing: 0) {
                        // Show bubble above emoji if active
                        if activeBubble?.id == element.id {
                            TouchBubble(message: element.tapMessage)
                                .padding(.bottom, 8)
                        }

                        // Emoji with floating animation
                        Text(element.emoji)
                            .font(.system(size: 36))
                            .modifier(FloatingAnimation())
                    }
                    .position(
                        x: geometry.size.width * element.xPercent,
                        y: geometry.size.height * element.yPercent
                    )
                    .simultaneousGesture(
                        TapGesture().onEnded {
                            handleTap(element: element)
                        }
                    )
                }
            }
        }
        .onDisappear {
            dismissTimer?.invalidate()
            dismissTimer = nil
        }
    }

    private func handleTap(element: TouchElement) {
        // Dismiss any existing bubble
        dismissTimer?.invalidate()
        dismissTimer = nil

        // Show new bubble
        withAnimation {
            activeBubble = element
        }

        // Schedule dismissal
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            withAnimation {
                activeBubble = nil
            }
            dismissTimer = nil
        }
    }
}

// MARK: - Floating Animation Modifier
struct FloatingAnimation: ViewModifier {
    @State private var isFloating = false

    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -6 : 6)
            .animation(
                Animation.easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

// MARK: - StoryTouchElements Helper
struct StoryTouchElements {
    static func elements(for storyId: String) -> [TouchElement]? {
        let map: [String: [TouchElement]] = [
            // Original 6 stories with touch elements
            "noah-big-boat": [
                TouchElement(emoji: "🌧️", xPercent: 0.15, yPercent: 0.25, tapMessage: "The rain fell for 40 days!"),
                TouchElement(emoji: "🕊️", xPercent: 0.85, yPercent: 0.35, tapMessage: "A dove found dry land!"),
                TouchElement(emoji: "🌈", xPercent: 0.5, yPercent: 0.1, tapMessage: "God's promise in the sky!")
            ],
            "david-and-goliath": [
                TouchElement(emoji: "🪨", xPercent: 0.2, yPercent: 0.4, tapMessage: "One small stone..."),
                TouchElement(emoji: "🛡️", xPercent: 0.8, yPercent: 0.3, tapMessage: "Faith is the best shield!"),
                TouchElement(emoji: "⭐", xPercent: 0.5, yPercent: 0.15, tapMessage: "You are brave too!")
            ],
            "the-good-samaritan": [
                TouchElement(emoji: "❤️", xPercent: 0.25, yPercent: 0.5, tapMessage: "Love your neighbor!"),
                TouchElement(emoji: "🩹", xPercent: 0.75, yPercent: 0.4, tapMessage: "Kindness heals!"),
                TouchElement(emoji: "🫏", xPercent: 0.5, yPercent: 0.25, tapMessage: "Help those in need!")
            ],
            "daniel-and-the-lions": [
                TouchElement(emoji: "😺", xPercent: 0.3, yPercent: 0.35, tapMessage: "The lions didn't hurt him!"),
                TouchElement(emoji: "👼", xPercent: 0.7, yPercent: 0.3, tapMessage: "God sent an angel!"),
                TouchElement(emoji: "🙏", xPercent: 0.5, yPercent: 0.6, tapMessage: "Prayer keeps us safe!")
            ],
            "creation-story": [
                TouchElement(emoji: "☀️", xPercent: 0.2, yPercent: 0.2, tapMessage: "Let there be light!"),
                TouchElement(emoji: "🌸", xPercent: 0.5, yPercent: 0.5, tapMessage: "Such beautiful flowers!"),
                TouchElement(emoji: "🐦", xPercent: 0.85, yPercent: 0.3, tapMessage: "All creatures praise God!")
            ],
            "jesus-calms-the-storm": [
                TouchElement(emoji: "🌊", xPercent: 0.2, yPercent: 0.4, tapMessage: "The waves were huge!"),
                TouchElement(emoji: "💨", xPercent: 0.8, yPercent: 0.25, tapMessage: "The wind obeyed Jesus!"),
                TouchElement(emoji: "✨", xPercent: 0.5, yPercent: 0.15, tapMessage: "Jesus has power over all!")
            ],
            // Additional stories with touch elements
            "the-lost-sheep": [
                TouchElement(emoji: "🐑", xPercent: 0.3, yPercent: 0.3, tapMessage: "Baa! Found you!"),
                TouchElement(emoji: "🌿", xPercent: 0.7, yPercent: 0.4, tapMessage: "Green pastures!"),
                TouchElement(emoji: "💕", xPercent: 0.5, yPercent: 0.15, tapMessage: "The shepherd loves every one!")
            ],
            "jonah-and-the-big-fish": [
                TouchElement(emoji: "🐋", xPercent: 0.5, yPercent: 0.4, tapMessage: "What a big fish!"),
                TouchElement(emoji: "🌊", xPercent: 0.2, yPercent: 0.25, tapMessage: "Splash into the sea!"),
                TouchElement(emoji: "🙏", xPercent: 0.8, yPercent: 0.15, tapMessage: "Jonah prayed inside the fish!")
            ],
            "the-birth-of-jesus": [
                TouchElement(emoji: "⭐", xPercent: 0.5, yPercent: 0.1, tapMessage: "The brightest star!"),
                TouchElement(emoji: "👶", xPercent: 0.5, yPercent: 0.5, tapMessage: "Baby Jesus is here!"),
                TouchElement(emoji: "🐑", xPercent: 0.2, yPercent: 0.35, tapMessage: "The shepherds came to visit!")
            ],
            "baby-moses": [
                TouchElement(emoji: "🧺", xPercent: 0.5, yPercent: 0.4, tapMessage: "Safe in the basket!"),
                TouchElement(emoji: "🌿", xPercent: 0.2, yPercent: 0.3, tapMessage: "Hidden in the reeds!"),
                TouchElement(emoji: "👸", xPercent: 0.8, yPercent: 0.2, tapMessage: "The princess found him!")
            ],
            "feeding-the-five-thousand": [
                TouchElement(emoji: "🍞", xPercent: 0.3, yPercent: 0.35, tapMessage: "Five loaves of bread!"),
                TouchElement(emoji: "🐟", xPercent: 0.7, yPercent: 0.35, tapMessage: "Two little fish!"),
                TouchElement(emoji: "✨", xPercent: 0.5, yPercent: 0.15, tapMessage: "A miracle for everyone!")
            ],
            "the-empty-tomb": [
                TouchElement(emoji: "✝️", xPercent: 0.5, yPercent: 0.15, tapMessage: "He is risen!"),
                TouchElement(emoji: "☀️", xPercent: 0.8, yPercent: 0.2, tapMessage: "A beautiful new morning!"),
                TouchElement(emoji: "👼", xPercent: 0.2, yPercent: 0.35, tapMessage: "The angel said: Do not be afraid!")
            ],
        ]
        return map[storyId]
    }
}

// MARK: - Preview
#Preview {
    InteractiveTouchOverlay(
        elements: StoryTouchElements.elements(for: "noah-big-boat") ?? []
    )
    .background(Color.blue.opacity(0.1))
}
