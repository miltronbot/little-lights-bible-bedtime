
import SwiftUI

struct TermsOfUseView: View {
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Use")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Group {
                    Text("Welcome to Firefly Bible Bedtime.")
                    Text("By using this app, you agree to these terms.")
                    Text("This app is intended for personal and family use.")
                    Text("Please do not copy, resell, or redistribute app content without permission.")
                    Text("We aim to provide calm, kid-friendly Bible bedtime stories for families, and content may be updated or improved over time. Stories are simplified retellings for young children, offered for educational and entertainment purposes only.")
                    Text("The app is completely free — no purchases, no ads, no subscriptions.")
                    Text("We work to keep the app functioning well, but uninterrupted access cannot be guaranteed at all times.")
                    Text("The app is provided \"as is,\" without warranties of any kind. To the maximum extent permitted by law, we are not liable for any damages arising from your use of the app, and our total liability is limited to the amount you paid for it ($0). Disputes are resolved by individual binding arbitration, with class actions and jury trials waived, as described in the full Terms of Use at miltronbot.github.io/little-lights-bible-bedtime/terms-of-use.html — the full Terms govern.")
                    Text("Support: Miltonbot@icloud.com")
                }
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Terms")
        .navigationBarTitleDisplayMode(.inline)
    }
}
