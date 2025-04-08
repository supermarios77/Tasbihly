import SwiftUI
import StoreKit

class CustomDhikrManager: NSObject, ObservableObject {
    static let shared = CustomDhikrManager()
    private let customDhikrsKey = "customDhikrs"
    private let productID = "com.tasbihly.premium"
    
    @Published private(set) var customDhikrs: [CustomDhikr] = []
    @Published private(set) var isPremiumUnlocked = false
    
    private var purchaseCompletion: ((Result<Bool, Error>) -> Void)?
    private var restoreCompletion: ((Result<Bool, Error>) -> Void)?
    
    private override init() {
        super.init()
        loadCustomDhikrs()
        checkPremiumStatus()
        SKPaymentQueue.default().add(self)
    }
    
    func addCustomDhikr(_ dhikr: CustomDhikr) {
        guard isPremiumUnlocked else { return }
        customDhikrs.append(dhikr)
        saveCustomDhikrs()
    }
    
    func deleteCustomDhikr(_ dhikr: CustomDhikr) {
        customDhikrs.removeAll { $0.id == dhikr.id }
        saveCustomDhikrs()
    }
    
    func purchasePremium(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard !isPremiumUnlocked else {
            completion(.success(true))
            return
        }
        
        purchaseCompletion = completion
        let request = SKProductsRequest(productIdentifiers: [productID])
        request.delegate = self
        request.start()
    }
    
    func restorePurchases(completion: @escaping (Result<Bool, Error>) -> Void) {
        restoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func checkPremiumStatus() {
        isPremiumUnlocked = UserDefaults.standard.bool(forKey: "isPremiumUnlocked")
    }
    
    private func saveCustomDhikrs() {
        if let encoded = try? JSONEncoder().encode(customDhikrs) {
            UserDefaults.standard.set(encoded, forKey: customDhikrsKey)
        }
    }
    
    private func loadCustomDhikrs() {
        if let data = UserDefaults.standard.data(forKey: customDhikrsKey),
           let decoded = try? JSONDecoder().decode([CustomDhikr].self, from: data) {
            customDhikrs = decoded
        }
    }
}

extension CustomDhikrManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let product = response.products.first else {
            purchaseCompletion?(.failure(StoreError.failedVerification))
            purchaseCompletion = nil
            return
        }
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    self.isPremiumUnlocked = true
                    UserDefaults.standard.set(true, forKey: "isPremiumUnlocked")
                    if transaction.transactionState == .purchased {
                        self.purchaseCompletion?(.success(true))
                        self.purchaseCompletion = nil
                    } else {
                        self.restoreCompletion?(.success(true))
                        self.restoreCompletion = nil
                    }
                }
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    if transaction.error?._code == SKError.paymentCancelled.rawValue {
                        self.purchaseCompletion?(.failure(StoreError.userCancelled))
                    } else {
                        self.purchaseCompletion?(.failure(StoreError.failedVerification))
                    }
                    self.purchaseCompletion = nil
                }
            case .deferred:
                DispatchQueue.main.async {
                    self.purchaseCompletion?(.failure(StoreError.pending))
                    self.purchaseCompletion = nil
                }
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.purchaseCompletion?(.failure(error))
            self.purchaseCompletion = nil
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        DispatchQueue.main.async {
            self.restoreCompletion?(.failure(error))
            self.restoreCompletion = nil
        }
    }
}

enum StoreError: Error {
    case failedVerification
    case userCancelled
    case pending
    case unknown
} 