
import SwiftUI

struct SupportView: View {
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        List {
            Section("Help") {
                if let supportURL = URL(string: "mailto:support@littlelightsbiblebedtime.com") {
                    Link("Email Support", destination: supportURL)
                }
                Text("Response goal: within 2 business days")
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

            Section("Common Questions") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("How do I restore my purchase?")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Open Settings and tap Restore Purchase.")
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Why is audio not playing?")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Make sure your device volume is on and the narration file is bundled with the app.")
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Support")
    }
}

// MARK: - Feedback & Ideas
// A direct line from families to us: suggest an idea, report something
// broken, or just say hello. Composes an email in the user's own mail app
// (parent-initiated, nothing collected automatically — COPPA-clean) with
// the app/iOS version attached so reports are actionable.

struct FeedbackView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.openURL) private var openURL

    enum Topic: String, CaseIterable, Identifiable {
        case idea = "Suggest an Idea"
        case problem = "Something Isn't Working"
        case feedback = "General Feedback"

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .idea: return "lightbulb.fill"
            case .problem: return "wrench.and.screwdriver.fill"
            case .feedback: return "bubble.left.and.bubble.right.fill"
            }
        }
        var subjectTag: String {
            switch self {
            case .idea: return "Idea"
            case .problem: return "Problem report"
            case .feedback: return "Feedback"
            }
        }
        var prompt: String {
            switch self {
            case .idea: return "What would make Firefly better for your family?"
            case .problem: return "What happened, and what did you expect instead?"
            case .feedback: return "We read every note — what's on your mind?"
            }
        }
    }

    @State private var topic: Topic = .idea
    @State private var message: String = ""
    @State private var showMailUnavailable = false

    private let supportAddress = "support@littlelightsbiblebedtime.com"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 10) {
                    LumiMascotView(size: 32, message: nil)
                    Text("Firefly gets better because families like yours tell us what to fix and what to dream up next.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)

                // Topic chips
                VStack(spacing: 10) {
                    ForEach(Topic.allCases) { t in
                        Button {
                            topic = t
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: t.icon)
                                    .font(.body)
                                    .frame(width: 26)
                                Text(t.rawValue)
                                    .font(.subheadline.bold())
                                Spacer()
                                Image(systemName: topic == t ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(topic == t
                                                     ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                                     : AppTheme.secondaryText(for: appSettings.isBedtimeMode).opacity(0.5))
                            }
                            .padding()
                            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(topic == t
                                            ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.7)
                                            : .clear, lineWidth: 1.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Message
                VStack(alignment: .leading, spacing: 8) {
                    Text(topic.prompt)
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    TextEditor(text: $message)
                        .frame(minHeight: 130)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Send — opens the user's own mail app, pre-filled
                Button {
                    send()
                } label: {
                    Label("Send to the Firefly Team", systemImage: "paperplane.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)

                Text("Opens your own mail app — nothing is sent or collected automatically. We aim to reply within 2 business days.")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Feedback & Ideas")
        .navigationBarTitleDisplayMode(.inline)
        .alert("No mail app found", isPresented: $showMailUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can email us directly at \(supportAddress).")
        }
    }

    private func send() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let body = """
        \(message)

        —
        \(topic.subjectTag) · Firefly \(appVersion) · iOS \(UIDevice.current.systemVersion)
        """

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportAddress
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Firefly — \(topic.subjectTag)"),
            URLQueryItem(name: "body", value: body),
        ]
        guard let url = components.url else { return }
        openURL(url) { accepted in
            if !accepted { showMailUnavailable = true }
        }
    }
}
