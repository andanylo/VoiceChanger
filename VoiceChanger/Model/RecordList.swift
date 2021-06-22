//
//  RecordList.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 17.03.2021.
//

import Foundation

///Class that holds and operates the record list
class RecordList{
    var list: [VoiceSound] = []
    
    ///Removes object from list
    func remove(at index: Int){
        if index < list.count{
            let object = list[index]
            do{
                try object.removeSound()
            }
            catch{
                
            }
            list.remove(at: index)
        }
    }
    
    ///Returns the array of records that matches the text
    func find(from name: String) -> [VoiceSound]{
        var newList: [VoiceSound] = []
        for sound in list{
            if sound.name.contains(name){
                newList.append(sound)
            }
        }
        return newList
    }
    
    ///Returns the object at index
    func returnObject(at index: Int) -> VoiceSound?{
        if index < list.count{
            return list[index]
        }
        return nil
    }
}
