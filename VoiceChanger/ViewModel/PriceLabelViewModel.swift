//
//  PriceLabelViewModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 05.11.2021.
//

import Foundation
import StoreKit
class PriceLabelViewModel{
    func getTextForLabel(for product: SKProduct?) -> String{
        guard let product = product else {
            return "$?.??"
        }

        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let price = product.price
        guard let string = numberFormatter.string(from: price) else{
            return "$?.??"
        }
        return string
    }
}
