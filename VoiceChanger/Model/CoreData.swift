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
        guard let effectsEntityDescription = NSEntityDescription.entity(forEntityName: "Effects", in: context) else{
            throw CoreDataError.unexpeted
        }
        
        ///Append or change entities in the context
        for sound in sounds{
            var newEntity: VoiceSoundEntity!
            if let entity = self.entities.first(where: {$0.path == sound.path}){
                newEntity = entity
            }
            else{
                newEntity = VoiceSoundEntity(entity: voiceEntityDescription, insertInto: context)
                newEntity = newEntity.convertFromObject(object: sound) as? VoiceSoundEntity
                
                self.entities.append(newEntity)
            }
            
            if let entityEffect = newEntity.effects{
                let effects = Effects(entity: entityEffect)
                if !effects.isEqual(sound.effects){
                    newEntity.effects = entityEffect.convertFromObject(object: sound.effects) as? EffectsEntity
                }
            }
            else{
                let effects = EffectsEntity(entity: effectsEntityDescription, insertInto: context)
                
                newEntity.effects = effects
            }
            
        }
        
        ///Remove entities if needed
        for entity in self.entities{
            if !sounds.contains(where: {$0.path == entity.path}){
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
                voiceSounds.append(VoiceSound(entity: entity))
            }
            return voiceSounds
        }
        catch{
            throw error
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
