//
//  IAP.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 05.11.2021.
//

import Foundation
import StoreKit

enum IAPState {
    case setProductIds
    case disabled
    case restored
    case purchased
    case failed
}
protocol IAPDelegate{
    func finish(state: IAPState)
    func didFecth(products: [SKProduct])
}


class IAP: NSObject {
    
    //MARK:- Shared Object
    //MARK:-
    static let shared = IAP()
    private override init() { }
    
    //MARK:- Properties
    //MARK:- Private
    fileprivate var productIds = [String]()
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    var products: [SKProduct] = []
    var delegate: IAPDelegate?
    
    
    fileprivate var productToPurchase: SKProduct?
    
    
    func isEmpty() -> Bool{
        return products.isEmpty
    }
    

    //MARK:- Methods
    //MARK:- Public
    
    //Set Product Ids
    func setProductIds(ids: [String]) {
        self.productIds = ids
    }

    //MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    
    func purchase() {
        guard let product = self.products.first else{
            return
        }
        self.productToPurchase = product

        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            productID = product.productIdentifier
        }
        else {
            self.delegate?.finish(state: .failed)
        }
    }
    
    // RESTORE PURCHASE
    func restorePurchase(){
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    // FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts(){
        
        // Put here your IAP Products ID's
        guard !self.productIds.isEmpty else{return}
   
        productsRequest = SKProductsRequest(productIdentifiers: Set(self.productIds))
        productsRequest.delegate = self
        productsRequest.start()
        
    }
    
}

//MARK: - Product Request Delegate and Payment Transaction Methods
//MARK: -
extension IAP: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    
    // REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            self.products = response.products
            delegate?.didFecth(products: response.products)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        delegate?.finish(state: .restored)
    }
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate?.finish(state: .failed)
    }
    
    // IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    UserDefaults.standard.set(true, forKey: "RemoveAds")
                    delegate?.finish(state: .purchased)
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    delegate?.finish(state: .failed)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    UserDefaults.standard.set(true, forKey: "RemoveAds")
                    delegate?.finish(state: .restored)
                    break
                    
                default: break
                }}}
    }
}
extension SKProduct {
    fileprivate static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }
    
    var localizedPrice: String {
        if self.price == 0.00 {
            return "Get"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale
            
            guard let formattedPrice = formatter.string(from: self.price) else {
                return "Unknown Price"
            }
            
            return formattedPrice
        }
    }
}
