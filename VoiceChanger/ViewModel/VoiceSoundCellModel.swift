//
//  VoiceSoundCellModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 17.03.2021.
//

import Foundation
import UIKit

class VoiceSoundCellModel{
    var voiceSound: VoiceSound?
    
    ///Returns the name of the cell
    var name: String?{
        get{
            return voiceSound?.name
        }
    }
    
    ///Height of the cell
    private var _height: CGFloat = 0.0
    var height: CGFloat{
        set(value){
            self._height = value
        }
        get{
            return isSelected == true ? self._height * 2 : self._height
        }
    }
    
    ///Area for cell
    var edges = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    ///Is currently selected
    var isSelected: Bool = false
    
    ///Returns the duration of voice sound in time components
    var duration: TimeComponents{
        get{
            guard let secondsDuration = voiceSound?.duration else{
                return TimeComponents()
            }
            var timeComponents = TimeComponents()
            timeComponents.minutes = Int(secondsDuration / 60)
            timeComponents.seconds = Int(secondsDuration) - timeComponents.minutes * 60
            timeComponents.miliseconds = Int((secondsDuration - Double(Int(secondsDuration))) * 10)
            return timeComponents
        }
    }
    
    init(voiceSound: VoiceSound?){
        self.voiceSound = voiceSound
        self.height = 70.0
    }
}
