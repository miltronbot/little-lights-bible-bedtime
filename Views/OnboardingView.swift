
import SwiftUI

// MARK: - First-Launch Onboarding Experience

struct OnboardingView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Binding var hasCompletedOnboarding: Bool

    @State private var childNames: [String] = [""]
    @State private var starScale: CGFloat = 0.5
    @State private var starOpacity: Double = 0.0
    @State private var showNameEntry: Bool = false
    @FocusState private var focusedField: Int?

    var body: some View {
        ZStack {
            // Deep night background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.12),
                    Color(red: 0.08, green: 0.06, blue: 0.18),
                    Color(red: 0.10, green: 0.08, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Scattered stars
            GeometryReader { geo in
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: CGFloat.random(in: 1.5...3.5), height: CGFloat.random(in: 1.5...3.5))
                        .opacity(Double.random(in: 0.3...0.8))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: 0...geo.size.height * 0.6)
                        )
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            if !showNameEntry {
                // Welcome screen
                welcomeScreen
            } else {
                // Name entry screen
                nameEntryScreen
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                starScale = 1.0
                starOpacity = 1.0
            }
        }
    }

    // MARK: - Welcome Screen

    private var welcomeScreen: some View {
        VStack(spacing: 30) {
            Spacer()

            // Animated moon and stars
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.indigo.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 30,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)

                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(starScale)
                    .opacity(starOpacity)
            }

            VStack(spacing: 14) {
                Text("Firefly")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Bible Bedtime")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.47, green: 0.52, blue: 0.95))

                Text("Beautiful Bible stories to help\nyour little one drift off to sleep")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showNameEntry = true
                }
            } label: {
                Text("Get Started")
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
            .padding(.bottom, 80)
        }
    }

    // MARK: - Name Entry Screen

    private var nameEntryScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 50))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 8) {
                Text("Who's listening tonight?")
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text("We'll personalize stories and bedtime\naffirmations just for them")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            // Name fields
            VStack(spacing: 12) {
                ForEach(0..<childNames.count, id: \.self) { index in
                    ChildNameRow(
                        name: $childNames[index],
                        index: index,
                        totalCount: childNames.count,
                        icon: childIcon(for: index),
                        color: childColor(for: index),
                        focusedField: $focusedField,
                        onRemove: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if index < childNames.count {
                                    childNames.remove(at: index)
                                }
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 32)

            // Add another child button
            if childNames.count < 4 {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        childNames.append("")
                        focusedField = childNames.count - 1
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add another child")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(Color(red: 0.47, green: 0.52, blue: 0.95))
                }
                .padding(.top, 4)
            }

            Spacer()

            // Continue button
            Button {
                saveAndContinue()
            } label: {
                Label("Start Exploring", systemImage: "arrow.right.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: hasValidName ? [.indigo, .purple] : [.gray.opacity(0.4), .gray.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .disabled(!hasValidName)
            .padding(.horizontal, 32)
            .padding(.bottom, 80)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
        }
    }

    // MARK: - Helpers

    private var hasValidName: Bool {
        childNames.contains { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private func saveAndContinue() {
        // Save all non-empty names
        let validNames = childNames
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        guard !validNames.isEmpty else { return }

        for name in validNames {
            appSettings.addChild(name: name)
        }
        appSettings.switchToChild(at: 0)

        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }

    private func childIcon(for index: Int) -> String {
        let icons = ["star.fill", "moon.fill", "sparkles", "heart.fill"]
        return icons[index % icons.count]
    }

    private func childColor(for index: Int) -> Color {
        let colors: [Color] = [.yellow, .cyan, .purple, .pink]
        return colors[index % colors.count]
    }
}

// MARK: - Child Name Row

private struct ChildNameRow: View {
    @Binding var name: String
    let index: Int
    let totalCount: Int
    let icon: String
    let color: Color
    var focusedField: FocusState<Int?>.Binding
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 28)

            TextField(
                "",
                text: $name,
                prompt: Text(index == 0 ? "Child's name" : "Another child's name")
                    .foregroundStyle(Color.white.opacity(0.3))
            )
            .font(.title3)
            .foregroundStyle(Color.white)
            .focused(focusedField, equals: index)
            .submitLabel(.done)

            if totalCount > 1 {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.white.opacity(0.3))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    focusedField.wrappedValue == index
                        ? Color(red: 0.47, green: 0.52, blue: 0.95)
                        : Color.white.opacity(0.15),
                    lineWidth: 1
                )
        )
    }
}
