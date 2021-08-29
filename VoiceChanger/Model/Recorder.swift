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
    
    
    
    ///Standard settings for recording files
    static let settings = [AVFormatIDKey: Int(kAudioFormatLinearPCM), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue]
    
    private var audioRecorder: AVAudioRecorder!
    
    ///Record timer to count how many seconds/minutes/miliseconds has been recordec
    var recordTimer: CustomTimer = CustomTimer(timeInterval: 0.001)
    
    ///State of the recorder
    var isRecording: Bool{
        get{
            guard let recorder = audioRecorder else{
                return false
            }
            return recorder.isRecording
        }
    }
    
    ///Delegate for recorder
    weak var delegate: RecorderDelegate?
    
    
    ///Voice sound to record
    private weak var voiceSoundToRecord: VoiceSound?
    
    
    init() {
        self.audioRecorder = AVAudioRecorder()
    }
    
    
    ///Function that validates and starts the recording
    func validateAndStart(voiceSound: VoiceSound, errorHandler: @escaping (Error?) -> Void){
       
        canRecordFiles { [weak self] (canRecord) in
            do{
                try self?.startRecording(voiceSound: voiceSound, canRecord: canRecord)
            }
            catch let error as RecordingError{
                errorHandler(error)
            }
            catch{
                errorHandler(error)
            }
        }
        
    }
    
    ///Function that starts the recording
    private func startRecording(voiceSound: VoiceSound, canRecord: Bool) throws{
        if !canRecord{
            throw RecordingError.cantRecordFiles
        }
        
        do{
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch{
            throw RecordingError.unexpexted(error)
        }
        do{

            guard let recordURL = voiceSound.url else{
                throw RecordingError.unknownURL
            }

            self.audioRecorder = try AVAudioRecorder(url: recordURL, settings: Recorder.settings)
            
            self.delegate?.didStartRecording()
            
            self.audioRecorder.prepareToRecord()

            self.audioRecorder.isMeteringEnabled = true
            
            self.audioRecorder.record()
            voiceSoundToRecord = voiceSound

            self.recordTimer.reset()
            self.recordTimer.start()

            
        }
        catch{
            throw RecordingError.unexpexted(error)
        }
        
    }
    
    
    ///Method that stops the recording
    func stopRecording(){
        
        self.delegate?.didStopRecording()
        
        self.audioRecorder.stop()
        
        self.voiceSoundToRecord?.updateAudioFile()
        self.voiceSoundToRecord = nil
        
        self.recordTimer.pause()
        
        Player.shared.setPlayback()
    }
    
    ///Returns current average power
    func averagePower() -> Float{
        self.audioRecorder.updateMeters()
        let averagePower = self.audioRecorder.averagePower(forChannel: 0)
        return averagePower
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
protocol RecorderDelegate: AnyObject{
    func didStartRecording()
    func didStopRecording()
}
