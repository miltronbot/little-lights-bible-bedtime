
import Foundation
import StoreKit

/// Product identifiers for in-app purchases.
enum StoreProduct {
    static let premiumUnlock = "com.littlelightsbible.premiumunlock"
}

/// Handles all StoreKit 2 interactions for purchasing and restoring
/// the premium library unlock.
final class PurchaseService {

    /// Fetch the premium unlock product from the App Store.
    func fetchPremiumProduct() async throws -> Product {
        let products = try await Product.products(for: [StoreProduct.premiumUnlock])
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        return product
    }

    /// Purchase the premium unlock non-consumable.
    /// Returns `true` when the purchase completes and is verified.
    func purchasePremiumUnlock() async throws -> Bool {
        let product = try await fetchPremiumProduct()
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            return true

        case .userCancelled:
            return false

        case .pending:
            // Transaction requires approval (e.g. Ask to Buy).
            return false

        @unknown default:
            return false
        }
    }

    /// Restore purchases by checking current entitlements.
    /// Returns `true` if the premium unlock is found.
    func restorePurchases() async throws -> Bool {
        // Sync with the App Store to pull latest transactions
        try await AppStore.sync()

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == StoreProduct.premiumUnlock {
                return true
            }
        }
        return false
    }

    /// Listen for transactions that complete outside of the app
    /// (e.g. interrupted purchases, family sharing changes, Ask to Buy approvals).
    func listenForTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                }
            }
        }
    }

    /// Check whether the user already owns the premium unlock.
    func checkExistingPurchase() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == StoreProduct.premiumUnlock {
                return true
            }
        }
        return false
    }

    // MARK: - Private

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw PurchaseError.verificationFailed(error)
        case .verified(let item):
            return item
        }
    }
}

// MARK: - Errors

enum PurchaseError: LocalizedError {
    case productNotFound
    case verificationFailed(Error)

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "The premium unlock product could not be found. Please try again later."
        case .verificationFailed:
            return "Purchase verification failed. Please try again or contact support."
        }
    }
}
