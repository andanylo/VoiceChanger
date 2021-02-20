//
//  DirectoryManager.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import Foundation

///Class that creates or returns the records directory
class DirectoryManager{
    
    ///Singleton
    static var shared = DirectoryManager()
    
    ///Returns the url for records directory
    private var recordsURL: URL?{
        get{
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{
                return nil
            }
            return documentDirectory.appendingPathComponent("Records", isDirectory: true)
        }
    }
    
    ///Returns boolean if records directory exists
    private var recordsDirectoryExists: Bool{
        get{
            guard let recordsURL = self.recordsURL else{
                return false
            }
            return FileManager.default.fileExists(atPath: recordsURL.path)
        }
    }
    
    ///Method that creates records directory
    private func createRecordsDirectory(){
        guard let recordsURL = self.recordsURL else{
            return
        }
        do{
            try FileManager.default.createDirectory(at: recordsURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch{
            
        }
    }
    
    func returnRecordsDirectory() -> URL?{
        if !recordsDirectoryExists{
            createRecordsDirectory()
        }
        return recordsURL
    }

}
