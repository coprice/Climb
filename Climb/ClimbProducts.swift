//
//  ClimbProducts.swift
//  Climb
//
//  Created by Collin Price on 6/20/17.
//  Copyright © 2017 Collin Price. All rights reserved.
//

import StoreKit

public struct ClimbProducts {
    
    public static let ExtraLife = "com.collinprice.Climb.ExtraLife"
    public static let SmallCoinBundle = "com.collinprice.Climb.SmallCoinBundle"
    public static let MediumCoinBundle = "com.collinprice.Climb.MediumCoinBundle"
    public static let LargeCoinBundle = "com.collinprice.Climb.LargeCoinBundle"
    public static let RemoveAds = "com.collinprice.Climb.RemoveAds"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> =
        [ClimbProducts.ExtraLife, ClimbProducts.SmallCoinBundle, ClimbProducts.MediumCoinBundle,
         ClimbProducts.LargeCoinBundle, ClimbProducts.RemoveAds]
    
    public static let store = IAPHelper(productIds: ClimbProducts.productIdentifiers)
    
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

