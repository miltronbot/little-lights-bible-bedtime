
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
        .background(AppTheme.background(for: appSettings.isBedtimeMode))
        .navigationTitle("Support")
    }
}
