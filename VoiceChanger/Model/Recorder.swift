//
//  Recorder.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import Foundation
import AVFoundation

///Class for recording audio files
class Recorder{
    
    ///Checks if microphone permission is enabled
    
    private func canRecordFiles(completion: @escaping (Bool) -> ()){
        
        switch AVCaptureDevice.authorizationStatus(for: .audio){
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { (permissionGranted) in
                completion(permissionGranted)
            }
        case .restricted:
            completion(false)
        case .denied:
            completion(false)
        case .authorized:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
    
    
    ///Standard settings for recording giles
    private let settings = [AVFormatIDKey: Int(kAudioFormatLinearPCM), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]
    
    
    var audioRecorder: AVAudioRecorder!
    var name: String?
    var fileName: String?
    
    ///Delegate for recorder
    var delegate: RecorderDelegate?
    
    ///Returns the record URL, based on file name
    private var recordURL: URL?{
        get{
            guard let recordsDirectory = DirectoryManager.shared.returnRecordsDirectory(), let fileName = self.fileName else{
                return nil
            }
            return recordsDirectory.appendingPathComponent(fileName)
        }
    }
    
    
    init() {
        self.audioRecorder = AVAudioRecorder()
    }
    
    
    ///Function that validates and starts the recording
    func validateAndStart(name: String){
       
        self.name = name
        self.fileName = name + ".m4a"
        
        canRecordFiles { (canRecord) in
            do{
                try self.startRecording(name: name, canRecord: canRecord)
            }
            catch let error as RecordingError{
                print(error.errorDescription ?? "")
            }
            catch{
                print(error.localizedDescription)
            }
        }
        
    }
    
    ///Function that starts the recording
    private func startRecording(name: String, canRecord: Bool) throws{
        if !canRecord{
            throw RecordingError.cantRecordFiles
        }
        
        do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch{
            throw RecordingError.unexpexted(error)
        }
        do{
            guard let recordURL = self.recordURL else{
                throw RecordingError.unknownURL
            }
            
            self.audioRecorder = try AVAudioRecorder(url: recordURL, settings: self.settings)
            self.audioRecorder.prepareToRecord()
            self.audioRecorder.record()
            
            self.delegate?.didStartRecording()
        }
        catch{
            throw RecordingError.unexpexted(error)
        }
        
    }
    
    
    ///Method that stops the recording
    func stopRecording(){
        self.audioRecorder.stop()
        
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch{
            
        }
    }
    
    ///Enum for errors with starting recording
    public enum RecordingError: Error{
        case unknownURL
        case cantRecordFiles
        case unexpexted(Error)
    }
}

///Localized custom error description
extension Recorder.RecordingError: LocalizedError{
    public var errorDescription: String?{
        switch self {
        case .unexpexted(let error):
            return error.localizedDescription
        case .unknownURL:
            return "Invalid URL of the record"
        case .cantRecordFiles:
            return "Can't record files. Check for permissions"
        }
    }
}
protocol RecorderDelegate{
    func didStartRecording()
    func didStopRecording()
}
