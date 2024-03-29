//
//  CoreData.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 22.02.2021.
//

import Foundation
import CoreData

///Singleton class that controls core database
class CoreData{
    
    static var shared = CoreData()
    
    var entities: [VoiceSoundEntity] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VoiceChanger")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
            }
        })
        return container
    }()

    ///Returns context of container
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    ///Saves data tpo persistantContainer's context
    func saveContext (sounds: [VoiceSound]) throws{
        guard let voiceEntityDescription = NSEntityDescription.entity(forEntityName: "VoiceSoundEntity", in: context) else{
            throw CoreDataError.unexpeted
        }
        guard let effectsEntityDescription = NSEntityDescription.entity(forEntityName: "EffectsEntity", in: context) else{
            throw CoreDataError.unexpeted
        }
        
        ///Append or change entities in the context
        var iterationNumber: Int = 0
        
        for sound in sounds{
            var newEntity: VoiceSoundEntity!
            if let entity = self.entities.first(where: {$0.lastPathComponent == sound.pathComponent}){
                newEntity = entity.convertFromObject(object: sound) as? VoiceSoundEntity
            }
            else{
                newEntity = VoiceSoundEntity(entity: voiceEntityDescription, insertInto: context)
                newEntity = newEntity.convertFromObject(object: sound) as? VoiceSoundEntity
                
                self.entities.append(newEntity)
            }
            newEntity.orderNumber = Int16(iterationNumber)
            
            if let entityEffect = newEntity.effects{
                let effects = Effects(entity: entityEffect)
                if !effects.isEqual(sound.effects){
                    newEntity.effects = entityEffect.convertFromObject(object: sound.effects) as? EffectsEntity
                }
            }
            else{
                var effects = EffectsEntity(entity: effectsEntityDescription, insertInto: context)
                effects = effects.convertFromObject(object: sound.effects) as! EffectsEntity
                newEntity.effects = effects
            }
            
            iterationNumber += 1
        }
        
        ///Remove entities if needed
        for entity in self.entities{
            if !sounds.contains(where: {$0.pathComponent == entity.lastPathComponent}){
                context.delete(entity)
            }
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw error
            }
        }
    }
    
    ///Fetch entities from core data
    func fetch() throws -> [VoiceSound] {
        let fetchRequest = NSFetchRequest<VoiceSoundEntity>(entityName: "VoiceSoundEntity")
        do{
            self.entities = try context.fetch(fetchRequest)
           
            var voiceSounds: [VoiceSound] = []
            for entity in self.entities{
                let voiceSound = VoiceSound(entity: entity)
                voiceSounds.append(voiceSound)
            }
            
            removeNotSavedFiles(voiceRecords: voiceSounds)
            
            voiceSounds.sort(by: { first,second in
                if let a = self.entities.first(where: {entity in entity.lastPathComponent == first.pathComponent})?.orderNumber, let b = self.entities.first(where: {entity in entity.lastPathComponent == second.pathComponent})?.orderNumber{
                    return a < b
                }
                return false
            })
            
            return voiceSounds
        }
        catch{
            throw error
        }
    }
    
    ///remove files, which are not saved
    func removeNotSavedFiles(voiceRecords: [VoiceSound]){
        do{
            guard let recordsDirectory = DirectoryManager.shared.returnRecordsDirectory() else{
                return
            }
            let recordFiles = try FileManager.default.contentsOfDirectory(atPath: recordsDirectory.path)
            try recordFiles.forEach({ file in
                if !voiceRecords.contains(where: {$0.url?.lastPathComponent == file}){
                   try FileManager.default.removeItem(atPath: recordsDirectory.appendingPathComponent(file).path)
                }
            })
        }
        catch{
        
        }
    }
    
    ///Core data errors
    enum CoreDataError: Error{
        case unexpeted
    }
}
protocol Entity{
    func convertFromObject<T>(object: T) -> NSManagedObject
}
