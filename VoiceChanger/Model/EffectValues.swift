//
//  EffectValues.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.07.2021.
//

import Foundation

///Class with effect values
class EffectValues{
    var speed: Float = 1.0{
        didSet{
            applyTransitionChanges?(.speed)
        }
    }
    var pitch: Float = 0.0{
        didSet{
            applyTransitionChanges?(.pitch)
        }
    }
    var distortion: Float = 0.0{
        didSet{
            applyTransitionChanges?(.distortion)
        }
    }
    var reverb: Float = 0.0{
        didSet{
            applyTransitionChanges?(.reverb)
        }
    }
    var volume: Float = 0.0{
        didSet{
            applyTransitionChanges?(.volume)
        }
    }
    var applyTransitionChanges: ((EffectPart) -> Void)?
    
    init(speed: Float, pitch: Float, distortion: Float, reverb: Float, volume: Float){
        self.speed = speed
        self.pitch = pitch
        self.distortion = distortion
        self.reverb = reverb
        self.volume = volume
    }
    init(){
        
    }
}
