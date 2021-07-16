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
    
    var effectTransitions: [EffectTransition] = []
    var applyTransitionChanges: ((EffectPart) -> Void)?
    
    ///Presets for default effects
    var distortionPreset: AVAudioUnitDistortionPreset?
    var reverbPreset: AVAudioUnitReverbPreset?
    
    
    private var originalSpeed: Float = 1.0
    private var originalPitch: Float = 0.0
    private var originalDistortion: Float = 0.0
    private var originalReverb: Float = 0.0
    
    ///Initialize the structure with parameters
    init(speed: Float, pitch: Float, distortion: Float, reverb: Float, distortionPreset: AVAudioUnitDistortionPreset?, reverbPreset: AVAudioUnitReverbPreset?){
        self.originalSpeed = speed
        self.originalPitch = pitch
        self.originalDistortion = distortion
        self.originalReverb = reverb
        
        self.speed = speed
        self.pitch = pitch
        self.distortion = distortion
        self.reverb = reverb
        
        self.distortionPreset = distortionPreset
        self.reverbPreset = reverbPreset

    }
    init(speed: Float, pitch: Float, distortion: Float, reverb: Float){
        self.originalSpeed = speed
        self.originalPitch = pitch
        self.originalDistortion = distortion
        self.originalReverb = reverb
        
        self.speed = speed
        self.pitch = pitch
        self.distortion = distortion
        self.reverb = reverb
    }
    
    
    ///Initialize from an entity
    init(entity: EffectsEntity){
        self.speed = entity.speed
        self.pitch = entity.pitch
        self.distortion = entity.distortion
        self.reverb = entity.reverb
        
        self.originalSpeed = self.speed
        self.originalPitch = self.pitch
        self.originalDistortion = self.distortion
        self.originalReverb = self.reverb
    }
    
    override init(){
        
    }
    ///Method that changes the effect
    func changeEffect(new value: Float, effectToChange: EffectPart){
        switch effectToChange {
        case .speed:
            self.speed = value
        case .pitch:
            self.pitch = value
        case .distortion:
            self.distortion = value
        case .reverb:
            self.reverb = value
        }
    }
    
    func getEffectValue(type: EffectPart) -> Float{
        switch type{
        case .speed:
            return self.originalSpeed
        case .pitch:
            return self.originalPitch
        case .distortion:
            return self.originalDistortion
        case .reverb:
            return self.originalReverb
        }
    }
    
    ///Reset effects
    func resetEffects(){
        self.speed = self.originalSpeed
        self.pitch = self.originalPitch
        self.distortion = self.originalDistortion
        self.reverb = self.originalReverb
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
        return self.speed == effects.speed && self.pitch == effects.pitch && self.distortion == effects.distortion && self.reverb == effects.reverb
    }
    
    ///Effect part
    enum EffectPart: CaseIterable{
        case speed
        case pitch
        case distortion
        case reverb
    }
    
}

///Inherit from protocol entity, which has a function to convert from object
extension EffectsEntity: Entity{
    func convertFromObject<T>(object: T) -> NSManagedObject {
        guard let effects = object as? Effects else{
            return self
        }
        self.speed = effects.speed
        self.pitch = effects.pitch
        self.distortion = effects.distortion
        self.reverb = effects.reverb
        return self
    }
}

 
