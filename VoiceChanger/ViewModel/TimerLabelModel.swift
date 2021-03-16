//
//  TimerLabelModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation

///View model for TimerLabel class
class TimerLabelModel{
    var format: String = "mm:ss.MM"
    
    init(format: String){
        self.format = format
    }
    
    ///mm - minutes
    ///ss - seconds
    ///MM - miliseconds
    func returnText(from components: TimeComponents) -> String{
        var text = format
        
        //Replace minutes from format
        text = text.replacingOccurrences(of: "mm", with: returnStringFromComponent(component: Int(components.minutes)))
        //Replace seconds from format
        text = text.replacingOccurrences(of: "ss", with: returnStringFromComponent(component: Int(components.seconds)))
        //Replace miliseconds from format
        text = text.replacingOccurrences(of: "MM", with: returnStringFromComponent(component: Int(components.miliseconds / 10)))
        
        return text
    }
    
    func returnText(from timer: CustomTimer?) -> String{
        return returnText(from: timer?.timeComponents ?? TimeComponents())
    }
    
    private func returnStringFromComponent(component: Int) -> String{
        return component < 10 ? "0\(component)" : "\(component)"
    }
    
    
}

