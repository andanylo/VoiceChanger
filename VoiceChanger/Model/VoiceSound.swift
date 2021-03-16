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
    
    ///Set path from lastPathComponent
    private func setPathLastPathComponent(lastPathComponent: String){
        guard let recordsDirectory = DirectoryManager.shared.returnRecordsDirectory() else{
            return
        }
        self.path = recordsDirectory.appendingPathComponent(lastPathComponent).path
    }
    
    
    var name: String = ""
    
    ///Returns the url from a file path
    var url: URL?{
        get{
            return URL(fileURLWithPath: path)
        }
    }
    
    ///Returns the boolean if file exists
    var fileExists: Bool{
        get{
            if path.isEmpty{
                return false
            }
            return FileManager.default.fileExists(atPath: path)
        }
    }
    
    
    
    ///Effects for the sound
    var effects: Effects = Effects()
    
    init(){
        self.setPathLastPathComponent(lastPathComponent: UUID().uuidString + ".m4a")
    }
    
    init(lastPathComponent: String){
        self.setPathLastPathComponent(lastPathComponent: lastPathComponent)
    }
    
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
