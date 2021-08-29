//
//  EffectPickerViewModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 28.08.2021.
//

import Foundation
import UIKit
class EffectPickerViewModel{
    var voiceSound: VoiceSound!
    
    var effectsTemplateViewModels = [EffectTemplateViewModel]()
    
    var selectedEffectsTemplate: EffectTemplateViewModel?{
        didSet{
            effectsTemplateViewModels.forEach({$0.isSelected = false})
            selectedEffectsTemplate?.isSelected = true
            guard let effects = selectedEffectsTemplate?.effects else{
                return
            }
            didPick?(effects)

        }
    }
    
    var didPick: ((Effects) -> Void)?
    var didClickOnCreate: (() -> Void)?
    
    var height: CGFloat = 60.0
    
    init(voiceSound: VoiceSound){
        self.voiceSound = voiceSound
        
        
        //low battery
        let lowbatteryEffect = Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0)
        lowbatteryEffect.effectTransitions = [EffectTransition(effects: lowbatteryEffect, startPoint: .custom(1/2), endPoint: .custom(1), fromValue: lowbatteryEffect.standardValues.speed, transitionValue: 0.2, effectPartToTransition: .speed),
                                              EffectTransition(effects: lowbatteryEffect, startPoint: .custom(1/2), endPoint: .custom(1), fromValue: 0, transitionValue: -500, effectPartToTransition: .pitch)
        ]
        
        //swirlEffect
        let duration = voiceSound.duration.returnSeconds()
        
        let swirlEffect = Effects(speed: 1, pitch: -500, distortion: 0, reverb: 0)
        let swirlEffectTransitionInterval = 0.2
        let swirlEffectCount = Int(duration / swirlEffectTransitionInterval)
        var swirlTransitions: [EffectTransition] = []
        
        for swirlCount in 0..<swirlEffectCount{
            let swirlTransition = EffectTransition(effects: swirlEffect, startPoint: .custom(Double(swirlCount) / Double(swirlEffectCount)), endPoint: .custom(Double(swirlCount + 1) / Double(swirlEffectCount)), fromValue: swirlCount % 2 == 0 ? -500 : 500, transitionValue: swirlCount % 2 == 0 ? 500 : -500, effectPartToTransition: .pitch)
            
            swirlTransitions.append(swirlTransition)
        }
        swirlEffect.effectTransitions = swirlTransitions
        
        [lowbatteryEffect, swirlEffect].forEach({effects.append($0)})
        
        self.effectsTemplateViewModels = effects.map({return EffectTemplateViewModel(type: .template, effects: $0)})
    }
    
    var effects = [
        ///Normal
        Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0),
        ///Drunk
        Effects(speed: 0.6, pitch: -100, distortion: 0, reverb: 0),
        ///Robot
        Effects(speed: 1, pitch: -400, distortion: 10, reverb: 0),
        ///small robot
        Effects(speed: 1, pitch: 400, distortion: 10, reverb: 0, distortionPreset: .multiEchoTight1, reverbPreset: nil),
        //Bee
        Effects(speed: 1.5, pitch: 1000, distortion: 5, reverb: 0, distortionPreset: .speechWaves, reverbPreset: nil),
        ///alien
        Effects(speed: 1, pitch: 200, distortion: 10, reverb: 0, distortionPreset: .speechCosmicInterference, reverbPreset: nil),
        ///Canyon
        Effects(speed: 1, pitch: 0, distortion: 100, reverb: 5, distortionPreset: .multiEcho2, reverbPreset: .cathedral),
        ///Scary/devil
        Effects(speed: 0.8, pitch: -1000, distortion: 0, reverb: 0),
        ///Fast and helium
        Effects(speed: 2, pitch: 2000, distortion: 0, reverb: 0),
        ///Slow
        Effects(speed: 0.5, pitch: -2000, distortion: 0, reverb: 0)
    ]
    
    
}
