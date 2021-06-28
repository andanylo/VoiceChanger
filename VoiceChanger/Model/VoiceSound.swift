//
//  VoiceSound.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 20.02.2021.
//

import Foundation
import CoreData

class VoiceSound{
    
    ///Structure with voice sound and it's current player state
    struct PlayerState{
        var isPlaying = false
        mutating func reset(){
            self.isPlaying = false
        }
    }
    
    var playerState: PlayerState = PlayerState()
    
    var pathComponent: String = ""
    
    ///Returns the url from a path component
    var url: URL?{
        get{
            guard let recordsDirectory = DirectoryManager.shared.returnRecordsDirectory() else{
                return nil
            }
            return recordsDirectory.appendingPathComponent(pathComponent)
        }
    }
    
    ///Returns the full path
    var fullPath: String{
        get{
            return self.url?.path ?? ""
        }
    }
    
    
    var name: String = ""
    
    ///Returns the boolean if file exists
    var fileExists: Bool{
        get{
            if fullPath.isEmpty{
                return false
            }
            return FileManager.default.fileExists(atPath: fullPath)
        }
    }
    
    ///Returns the audio file of voice sound
    var audioFile: AudioFile?
    
    ///Returns the duration of recording in seconds
    private var _duration: Double{
        get{
            return audioFile == nil ? 0.0 : audioFile!.duration
        }
    }
    
    ///Returns the duration of voice sound in time components
    var duration: TimeComponents{
        get{
            let secondsDuration = self._duration
            return TimeComponents(seconds: secondsDuration)
        }
    }
    
    
    ///Effects for the sound
    var effects: Effects = Effects(){
        didSet{
            ///Configure effect transitions
            oldValue.effectTransitions.forEach({transition in
                transition.fileDuration = nil
                transition.fileDurationFrames = nil
            })
            oldValue.applyTransitionChanges = nil
            
            effects.effectTransitions.forEach({ [unowned self] transition in
                transition.fileDuration = {
                    return self.duration
                }
                transition.fileDurationFrames = {
                    return self.audioFile?.frameCount ?? 0
                }
            })
        }
    }
    
    init(){
        self.pathComponent = UUID().uuidString + ".m4a"
    }
    
    init(lastPathComponent: String){
        self.pathComponent = lastPathComponent
    }
    
    init(lastPathComponent: String, name: String){
        self.pathComponent = lastPathComponent
        self.name = name
    }
    
    init(entity: VoiceSoundEntity){
        self.pathComponent = entity.lastPathComponent ?? ""
        self.name = entity.name ?? ""
        self.effects = Effects(entity: entity.effects!)
        self.updateAudioFile()
    }
    
    ///Removes the sound
    func removeSound() throws{
        if fileExists{
            do{
                guard let url = self.url else{
                    return
                }
                try FileManager.default.removeItem(at: url)
            }
            catch{
                throw error
            }
        }
    }
    
    ///Updates the audio file
    func updateAudioFile(){
        guard let url = self.url, fileExists else{
            return
        }
        do{
            let audioFile = try AudioFile(forReading: url)
            self.audioFile = audioFile
        }
        catch{
        }
    }
    
}

///Conform the protocol  entity, which has functoin convertToEntity.
extension VoiceSoundEntity: Entity{
    func convertFromObject<T>(object: T) -> NSManagedObject {
        guard let voiceSound = object as? VoiceSound else{
            return self
        }
        self.lastPathComponent = voiceSound.pathComponent
        self.name = voiceSound.name
        return self
    }
}
