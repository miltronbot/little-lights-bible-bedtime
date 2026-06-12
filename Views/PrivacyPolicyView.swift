
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
                    Text("Firefly Bible Bedtime is designed to keep things simple and private.")
                    Text("We do not require users to create an account.")
                    Text("We do not collect any personal information, and there are no ads, analytics, or tracking of any kind.")
                    Text("We do not knowingly collect data from children.")
                    Text("The app may store limited information locally on your device, such as favorite stories, bedtime mode preference, and reading progress, streaks, and rewards. It stays on your device (and in your personal iCloud account if you enable iCloud sync) and is never sent to us or any third party.")
                    Text("The app is completely free. There are no purchases, so no payment information is ever involved.")
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
