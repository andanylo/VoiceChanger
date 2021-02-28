//
//  Effects.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 20.02.2021.
//

import Foundation
import CoreData

///Structure that has effects for the sound
class Effects: NSObject{
    var speed: Float = 1.0
    var pitch: Float = 0.0
    var distortion: Float = 0.0
    var reverb: Float = 0.0
    
    
    ///Initialize the structure with parameters
    init(speed: Float, pitch: Float, distortion: Float, reverb: Float){
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
    }
    
    override init(){
        
    }
    
    ///Method that checks if other Effects class is equal
    override func isEqual(_ object: Any?) -> Bool {
        guard let effects = object as? Effects else{
            return false
        }
        return self.speed == effects.speed && self.pitch == effects.pitch && self.distortion == effects.distortion && self.reverb == effects.reverb
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

 
