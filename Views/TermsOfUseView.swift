
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
                    Text("Welcome to Firefly Bible Bedtime for Kids.")
                    Text("By using this app, you agree to these simple terms.")
                    Text("This app is intended for personal and family use.")
                    Text("Please do not copy, resell, or redistribute app content without permission.")
                    Text("We aim to provide calm, kid-friendly Bible bedtime stories for families, and content may be updated or improved over time.")
                    Text("Premium content is offered as a one-time in-app purchase. Payments are processed by Apple through the App Store, and we do not store payment details.")
                    Text("We work to keep the app functioning well, but uninterrupted access cannot be guaranteed at all times.")
                    Text("Support: support@littlelightsbiblebedtime.com")
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
