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
        let lowbatteryEffect = Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0, volume: 1)
        lowbatteryEffect.effectTransitions = [EffectTransition(effects: lowbatteryEffect, startPoint: .custom(1/2), endPoint: .custom(1), fromValue: lowbatteryEffect.standardValues.speed, transitionValue: 0.2, effectPartToTransition: .speed),
                                              EffectTransition(effects: lowbatteryEffect, startPoint: .custom(1/2), endPoint: .custom(1), fromValue: 0, transitionValue: -500, effectPartToTransition: .pitch)
        ]
        
        let duration = voiceSound.duration.returnSeconds()
        //swirlEffect
        
        let swirlEffect = Effects(speed: 1, pitch: -800, distortion: 0, reverb: 0, volume: 1)
        effectMakeRepeatTransitions(effect: swirlEffect, interval: 0.2, firstValue: -600, secondValue: 600, voiceSoundDuration: duration, effectPart: .pitch)

        //fan effect
        let fanEffect = Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0, volume: 1)
        effectMakeRepeatTransitions(effect: fanEffect, interval: 0.065, firstValue: 1, secondValue: 0, voiceSoundDuration: duration, effectPart: .volume)
        
        [lowbatteryEffect, swirlEffect, fanEffect].forEach({effects.append($0)})
        
        
        
        
        self.effectsTemplateViewModels = effects.map({return EffectTemplateViewModel(type: .template, effects: $0)})
    }
    
    func effectMakeRepeatTransitions(effect: Effects, interval: Double, firstValue: Float, secondValue: Float, voiceSoundDuration: Double, effectPart: EffectPart){
        let effectCount = Int(voiceSoundDuration / interval)
        var effectTransitions: [EffectTransition] = []
        for count in 0..<effectCount{
            let transition = EffectTransition(effects: effect, startPoint: .custom(Double(count) / Double(effectCount)), endPoint: .custom(Double(count + 1) / Double(effectCount)), fromValue: count % 2 == 0 ? firstValue : secondValue, transitionValue: count % 2 == 0 ? secondValue : firstValue, effectPartToTransition: effectPart)
            
            effectTransitions.append(transition)
        }
        effect.effectTransitions = effectTransitions
    }
    
    var effects = [
        ///Normal
        Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0, volume: 1),
        ///Drunk
        Effects(speed: 0.6, pitch: -100, distortion: 0, reverb: 0, volume: 1),
        ///Robot
        Effects(speed: 1, pitch: -400, distortion: 10, reverb: 0, volume: 1),
        ///small robot
        Effects(speed: 1, pitch: 400, distortion: 10, reverb: 0, volume: 1, distortionPreset: .multiEchoTight1, reverbPreset: nil),
        //Bee
        Effects(speed: 1.5, pitch: 1000, distortion: 5, reverb: 0, volume: 1, distortionPreset: .speechWaves, reverbPreset: nil),
        ///alien
        Effects(speed: 1, pitch: 200, distortion: 10, reverb: 0, volume: 1, distortionPreset: .speechCosmicInterference, reverbPreset: nil),
        ///Canyon
        Effects(speed: 1, pitch: 0, distortion: 100, reverb: 5, volume: 1, distortionPreset: .multiEcho2, reverbPreset: .cathedral),
        ///Scary/devil
        Effects(speed: 0.8, pitch: -1000, distortion: 0, reverb: 0, volume: 1),
        ///helium
        Effects(speed: 1, pitch: 1000, distortion: 0, reverb: 0, volume: 1),
        ///Slow
        Effects(speed: 0.5, pitch: -2000, distortion: 0, reverb: 0, volume: 1),
        ///Megaphone
        Effects(speed: 1, pitch: 0, distortion: 50, reverb: 0, volume: 1, distortionPreset: .multiDecimated2, reverbPreset: nil),
        ///Chimpchunk
        Effects(speed: 1.2, pitch: 1300, distortion: 0, reverb: 0, volume: 1),
        ///Huge echo
        Effects(speed: 1, pitch: 0, distortion: 0, reverb: 60, volume: 1)
    ]
    
    
}
