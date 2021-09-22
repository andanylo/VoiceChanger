//
//  Effects.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 20.02.2021.
//

import Foundation
import CoreData
import AVFoundation


///Structure that has effects for the sound
class Effects: NSObject{
    var currentValues: EffectValues = EffectValues()
    var standardValues: EffectValues = EffectValues()
    
    var effectTransitions: [EffectTransition] = []
    
    ///Presets for default effects
    var distortionPreset: AVAudioUnitDistortionPreset?
    var reverbPreset: AVAudioUnitReverbPreset?
    
    ///Initialize the structure with parameters
    init(speed: Float, pitch: Float, distortion: Float, reverb: Float, volume: Float, distortionPreset: AVAudioUnitDistortionPreset?, reverbPreset: AVAudioUnitReverbPreset?){
        self.standardValues = EffectValues(speed: speed, pitch: pitch, distortion: distortion, reverb: reverb, volume: volume)
        self.currentValues = EffectValues(speed: speed, pitch: pitch, distortion: distortion, reverb: reverb, volume: volume)
        
        self.distortionPreset = distortionPreset
        self.reverbPreset = reverbPreset

    }
    init(speed: Float, pitch: Float, distortion: Float, reverb: Float, volume: Float){
        self.standardValues = EffectValues(speed: speed, pitch: pitch, distortion: distortion, reverb: reverb, volume: volume)
        self.currentValues = EffectValues(speed: speed, pitch: pitch, distortion: distortion, reverb: reverb, volume: volume)
    }
    
    
    ///Initialize from an entity
    init(entity: EffectsEntity){
        self.standardValues = EffectValues(speed: entity.speed, pitch: entity.pitch, distortion: entity.distortion, reverb: entity.reverb, volume: entity.volume)
        self.currentValues = EffectValues(speed: entity.speed, pitch: entity.pitch, distortion: entity.distortion, reverb: entity.reverb, volume: entity.volume)
    }
    
    override init(){
        
    }
    ///Method that changes the effect
    func changeEffect(new value: Float, effectToChange: EffectPart){
        switch effectToChange {
        case .speed:
            self.currentValues.speed = value
        case .pitch:
            self.currentValues.pitch = value
        case .distortion:
            self.currentValues.distortion = value
        case .reverb:
            self.currentValues.reverb = value
        case .volume:
            self.currentValues.volume = value
        }
    }
    
    func getEffectValue(type: EffectPart) -> Float{
        switch type{
        case .speed:
            return self.standardValues.speed
        case .pitch:
            return self.standardValues.pitch
        case .distortion:
            return self.standardValues.distortion
        case .reverb:
            return self.standardValues.reverb
        case .volume:
            return self.standardValues.volume
        }
    }
    
    ///Reset effects
    func resetEffects(){
        self.currentValues = EffectValues(speed: self.standardValues.speed, pitch: self.standardValues.pitch, distortion: self.standardValues.distortion, reverb: self.standardValues.reverb, volume: self.standardValues.volume)
    }
    ///Expected value at seconds
    func expectedValue(for effect: EffectPart, at seconds: Double) -> Float{
        let standardValue = getEffectValue(type: effect)
        let newEffectTransitions = effectTransitions.filter({$0.effectPartToTransition == effect})
        
        if !newEffectTransitions.isEmpty{
            
            ///Retrun the value during transition
            if let effectTransition = newEffectTransitions.first(where: {seconds >= $0.startPointSeconds && seconds <= $0.endPointSeconds}){
                return effectTransition.expectedValue(updateInterval: 0.01, currentPlayerTime: seconds)
            }
            
            ///Return in-between value between transitions or start
            for i in 0..<newEffectTransitions.count{
                let previousTransition: EffectTransition? = i == 0 ? nil : effectTransitions[i-1]
                let currentTransition = effectTransitions[i]
                
                if seconds < currentTransition.endPointSeconds && seconds > (previousTransition?.startPointSeconds ?? 0){
                    return previousTransition?.transitionValue ?? standardValue
                }
            }
            
            ///Return the end value of effect, if it is the last effect
            if seconds > newEffectTransitions.last!.endPointSeconds{
                return newEffectTransitions.last!.transitionValue
            }
        }
        return standardValue
    }
    
    ///Method that checks if other Effects class is equal
    override func isEqual(_ object: Any?) -> Bool {
        guard let effects = object as? Effects else{
            return false
        }
        return standardValues.speed == effects.standardValues.speed && standardValues.pitch == effects.standardValues.pitch && standardValues.distortion == effects.standardValues.distortion && standardValues.reverb == effects.standardValues.reverb
    }
    
    
}
///Effect part
enum EffectPart: CaseIterable{
    case speed
    case pitch
    case distortion
    case reverb
    case volume
}


///Inherit from protocol entity, which has a function to convert from object
extension EffectsEntity: Entity{
    func convertFromObject<T>(object: T) -> NSManagedObject {
        guard let effects = object as? Effects else{
            return self
        }
        self.speed = effects.standardValues.speed
        self.pitch = effects.standardValues.pitch
        self.distortion = effects.standardValues.distortion
        self.reverb = effects.standardValues.reverb
        self.volume = effects.standardValues.volume
        return self
    }
}

 
