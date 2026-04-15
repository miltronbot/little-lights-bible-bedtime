
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
                    Text("Little Lights Bible Bedtime for Kids is designed to keep things simple and private.")
                    Text("We do not require users to create an account.")
                    Text("We do not collect personal information for version 1 of the app.")
                    Text("We do not knowingly collect data from children.")
                    Text("The app may store limited information locally on your device, such as favorite stories, bedtime mode preference, and premium unlock status.")
                    Text("If you choose to unlock premium content, purchases are processed by Apple through the App Store. We do not store payment information.")
                    Text("Support: support@littlelightsbiblebedtime.com")
                }
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
            .padding()
        }
        .background(AppTheme.background(for: appSettings.isBedtimeMode))
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
