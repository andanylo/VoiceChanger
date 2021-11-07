//
//  Ads.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 06.11.2021.
//

import Foundation
import GoogleMobileAds
class Ads{
    static let shared = Ads()
    
    var interstital: GADInterstitialAd?
    var showNum = 0
    var numToShowAd = 2
    
    func loadAd(fullScreenContentDelegate: GADFullScreenContentDelegate?){
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-6536053754867445/9148026501",
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self.interstital = ad
            self.interstital?.fullScreenContentDelegate = fullScreenContentDelegate
        })
    }
}
