//
//  TimeComponents.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 16.03.2021.
//

import Foundation

///Structure that divides the time to seconds minutes and miliseconds
struct TimeComponents{
    var seconds: Int = 0
    var minutes: Int = 0
    var miliseconds: Int = 0
    func returnCombinedMiliseconds() -> Int{
        return self.miliseconds + self.seconds * 1000 + self.minutes * 60 * 1000
    }
    func returnSeconds() -> Double{
        let minutesToSeconds = self.minutes * 60
        let seconds = minutesToSeconds + self.seconds
        let milisecondsToSeconds = Double(miliseconds) / 1000
        return Double(seconds) + milisecondsToSeconds
    }
    mutating func convertFromMiliseconds(miliseconds: Int){
        ///Set miliseconds
        self.miliseconds = miliseconds - Int(Double(miliseconds / 1000)) * 1000
        
        ///Set minutes
        self.minutes = miliseconds / 1000 / 60
        
        ///Set seconds
        self.seconds = miliseconds / 1000 - self.minutes * 60
    }
    mutating func convertFromSeconds(seconds: Double){
        self.minutes = Int(seconds / 60)
        self.seconds = Int(Int(seconds) - self.minutes * 60)
        self.miliseconds = Int((seconds - Double(Int(seconds))) * 1000)
        
    }
}
