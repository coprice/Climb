//
//  IAPHelper.swift
//  Climb
//
//  Created by Collin Price on 6/20/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 */

import SpriteKit
import StoreKit
import FBSDKCoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> ()

open class IAPHelper : NSObject  {
    
    var products: [SKProduct] = [SKProduct]()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    fileprivate let productIdentifiers: Set<ProductIdentifier>
    fileprivate var purchasedProductIdentifiers = Set<ProductIdentifier>()
    fileprivate var productsRequest: SKProductsRequest?
    fileprivate var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    static let IAPHelperPurchaseNotification = "IAPHelperPurchaseNotification"
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    public func startSpinner() {
        print("spinner started")
        spinner.center = CGPoint(x: viewDelegate.view.frame.width / 2, y: viewDelegate.view.frame.height * 0.05)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        viewDelegate.view.addSubview(spinner)
    }
    
    public func stopSpinner() {
        print("spinner stopped")
        spinner.stopAnimating()
    }
}

// MARK: - StoreKit API

extension IAPHelper {
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
    
    public func buyProduct(_ product: SKProduct) {
        startSpinner()
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

extension IAPHelper: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("Transaction complete...")
        let identifier = transaction.payment.productIdentifier
        
        requestingPurchase = false
        self.stopSpinner()
        
        // update information locally
        switch identifier {
            
        case "com.collinprice.Climb.ExtraLife":
            defaults.set(defaults.integer(forKey: "extralives") + 1, forKey: "extralives")
        case "com.collinprice.Climb.SmallCoinBundle":
            defaults.set(defaults.integer(forKey: "coins") + 100, forKey: "coins")
        case "com.collinprice.Climb.MediumCoinBundle":
            defaults.set(defaults.integer(forKey: "coins") + 275, forKey: "coins")
        case "com.collinprice.Climb.LargeCoinBundle":
            defaults.set(defaults.integer(forKey: "coins") + 850, forKey: "coins")
        case "com.collinprice.Climb.RemoveAds":
            defaults.set(false, forKey: "ads")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShop"), object: nil)
        default: break
        }
        
        if FBSDKAccessToken.current() != nil {
            
            // save information to the backend
            API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: nil, ads: defaults.bool(forKey: "ads"), extra_lives: defaults.integer(forKey: "extralives"), completion_handler: {
                (response, _) in
                
                if response != URLResponse.Success {
                    
                    defaults.set(true, forKey: "unsaved")
                    print("purchase not saved. unsaved bool triggered")
                    return
                }
                print("purchase saved to backend")
                
            })
        }
        
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("Restoring transactions... \(productIdentifier)")
        
        if defaults.bool(forKey: "ads") && productIdentifier == "com.collinprice.Climb.RemoveAds" {
            defaults.set(false, forKey: "ads")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadShop"), object: nil)
            Cache.createAlert(title: "Restoration Successful!", message: "", view: viewDelegate)
            
            // save information to the backend
            if FBSDKAccessToken.current() != nil {
                
                API.save_user_info(fb_id: FBSDKAccessToken.current().userID, coins: defaults.integer(forKey: "coins"), sprites: nil, ads: defaults.bool(forKey: "ads"), extra_lives: defaults.integer(forKey: "extralives"), completion_handler: {
                    (response, _) in
                    
                    if response != URLResponse.Success {
                        
                        defaults.set(true, forKey: "unsaved")
                        print("restoration not saved. unsaved bool triggered")
                        return
                    }
                    print("restoration saved to backend")
                    
                })
            }
        }
        
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("Transaction failure...")
        requestingPurchase = false
        self.stopSpinner()
        
        if let transactionError = transaction.error {
            switch transactionError {
            case SKError.clientInvalid:
                // client is not allowed to issue the request, etc.
                print("clientInvalid")
                break;
            case SKError.cloudServiceNetworkConnectionFailed:
                print("cloudServiceNetworkConnectionFailed")
                break;
            case SKError.cloudServicePermissionDenied:
                print("cloudServicePermissionDenied")
                break;
            case SKError.paymentCancelled:
                // this device is not allowed to make the payment
                print("paymentCancelled")
                break;
            case SKError.paymentInvalid:
                // user cancelled the request, etc.
                print("paymentInvalid")
                break;
            case SKError.paymentNotAllowed:
                print("payment not allowed")
                break;
            case SKError.storeProductNotAvailable:
                print("storeProductNotAvailable")
                break;
            case SKError.unknown:
                // Unknown error
                Cache.createAlert(title: "Cannot Connect to Itunes Store", message: "", view: viewDelegate)
                print("unknown error")
                break;
            default:
                break;
            }
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        
        purchasedProductIdentifiers.insert(identifier)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification), object: identifier)
    }
}


