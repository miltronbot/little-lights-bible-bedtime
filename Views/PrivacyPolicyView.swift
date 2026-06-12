
import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Group {
                    Text("Firefly Bible Bedtime is designed to keep things simple and private. We have no servers and never receive any data about you or your child.")
                    Text("We do not require users to create an account.")
                    Text("We do not collect any personal information, and there are no ads, analytics, or tracking of any kind.")
                    Text("We do not knowingly collect data from children.")
                    Text("The app may store limited information locally on your device, such as optional child profile names, favorite stories, bedtime mode preference, and reading progress, streaks, and rewards. With iCloud enabled it syncs through your own iCloud account under Apple's privacy policy — never visible to us.")
                    Text("Microphone access is requested only if a parent records their own narration. Recordings stay on your device, can be deleted in the app anytime, and are never uploaded or shared. Bedtime reminders, if enabled, are local notifications that never leave your device.")
                    Text("Optional narration service: only if a parent adds their own ElevenLabs API key in Settings, story text (never personal information) is sent to ElevenLabs to generate narration, under ElevenLabs' own privacy policy.")
                    Text("The app is completely free. There are no purchases, so no payment information is ever involved.")
                    Text("Because we hold no data about you, there is nothing for us to access, correct, delete, sell, or share. Full policy: miltronbot.github.io/little-lights-bible-bedtime/privacy-policy.html")
                    Text("Support: Miltonbot@icloud.com")
                }
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
