
import Foundation
import StoreKit

@MainActor
final class PurchaseViewModel: ObservableObject {
    @Published private(set) var hasPremium: Bool = true
    @Published var isProcessingPurchase: Bool = false
    @Published var purchaseErrorMessage: String?
    @Published var premiumProduct: Product?

    init() {
        // All content is completely free — no purchase needed
        // Premium flag is true by default so all stories are accessible
    }

    func canAccess(_ story: Story) -> Bool {
        return true // All stories are free
    }

    func purchasePremium() async {
        // All content is free — this is a no-op placeholder
        // If you add StoreKit integration later, implement purchase logic here
        isProcessingPurchase = false
        hasPremium = true
    }

    func restorePurchases() async {
        // All content is free — this is a no-op placeholder
        // If you add StoreKit integration later, implement restore logic here
        isProcessingPurchase = false
        hasPremium = true
    }
}
