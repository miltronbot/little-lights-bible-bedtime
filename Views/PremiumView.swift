
import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var purchaseViewModel: PurchaseViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero section
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.accent(for: appSettings.isBedtimeMode),
                                AppTheme.secondaryAccent(for: appSettings.isBedtimeMode).opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 42))
                                .foregroundStyle(.white)
                            Text("Unlock All Bedtime Stories")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                            Text("Get all 50 calming Bible bedtime stories for one simple unlock.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.white.opacity(0.9))
                                .padding(.horizontal)
                        }
                    }

                // Feature list
                VStack(alignment: .leading, spacing: 14) {
                    PremiumFeatureRow(text: "Unlock all premium bedtime stories")
                    PremiumFeatureRow(text: "Audio narration for every story")
                    PremiumFeatureRow(text: "Simple one-time family purchase")
                    PremiumFeatureRow(text: "No subscriptions, no ads, ever")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Purchase buttons
                VStack(spacing: 12) {
                    Button {
                        Task {
                            await purchaseViewModel.purchasePremium()
                            if purchaseViewModel.hasPremium { dismiss() }
                        }
                    } label: {
                        HStack {
                            if purchaseViewModel.isProcessingPurchase {
                                ProgressView().tint(.white)
                            }
                            if let price = purchaseViewModel.premiumProduct?.displayPrice {
                                Text("Unlock Full Library — \(price)")
                                    .font(.headline)
                            } else {
                                Text("Unlock Full Library")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(purchaseViewModel.isProcessingPurchase)

                    Button {
                        Task {
                            await purchaseViewModel.restorePurchases()
                            if purchaseViewModel.hasPremium { dismiss() }
                        }
                    } label: {
                        Text("Restore Purchase")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .disabled(purchaseViewModel.isProcessingPurchase)
                }

                if let errorMessage = purchaseViewModel.purchaseErrorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Text("Parent area: purchases should be completed by an adult.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
    }
}
