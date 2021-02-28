//
//  VoiceSound.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 20.02.2021.
//

import Foundation
import CoreData

class VoiceSound{
    
    var path: String = ""
    var name: String = ""
    
    ///Returns the url from a file path
    var url: URL?{
        get{
            return URL(fileURLWithPath: path)
        }
    }
    
    ///Effects for the sound
    var effects: Effects = Effects()
    
    init(path: String, name: String){
        self.path = path
        self.name = name
    }
    
    init(entity: VoiceSoundEntity){
        self.path = entity.path ?? ""
        self.name = entity.name ?? ""
        self.effects = Effects(entity: entity.effects!)
    }
}

///Conform the protocol  entity, which has functoin convertToEntity.
extension VoiceSoundEntity: Entity{
    func convertFromObject<T>(object: T) -> NSManagedObject {
        guard let voiceSound = object as? VoiceSound else{
            return self
        }
        self.path = voiceSound.path
        self.name = voiceSound.name
        return self
    }
}
