//
//  Player.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 20.02.2021.
//

import Foundation
import AVFoundation

///Class that plays an audio file with effects
class Player{
    static var shared = Player()
    
    ///Structure that has all audio nodes
    struct AudioNodes{
        var audioEngine: AudioEngine
        var audioPlayer: AudioPlayerNode
        var pitchAndSpeedNode: AVAudioUnitTimePitch
        var distortionNode: AVAudioUnitDistortion
        var reverbNode: AVAudioUnitReverb

        func setEffects(effects: Effects?){
            let soundEffects = effects ?? Effects()
            
            self.pitchAndSpeedNode.rate = soundEffects.speed
            self.pitchAndSpeedNode.pitch = soundEffects.pitch
            self.distortionNode.wetDryMix = soundEffects.distortion
            self.reverbNode.wetDryMix = soundEffects.reverb
            self.reverbNode.loadFactoryPreset(.cathedral)
        }
        
    }
    
    private var audioNodes: AudioNodes!
    
    var delegate: PlayerDelegate?
    
    var isPaused: Bool = false
    
    ///Initializtion that initiates an audio engine
    init(){
        self.audioNodes = AudioNodes(audioEngine: AudioEngine(), audioPlayer: AudioPlayerNode(), pitchAndSpeedNode: AVAudioUnitTimePitch(), distortionNode: AVAudioUnitDistortion(), reverbNode: AVAudioUnitReverb())
    }
    
    ///Play an audio file from path
    func playFile(filePath: String, effects: Effects?) throws{
        let url = URL(fileURLWithPath: filePath)
        do{
            try playFile(url: url, effects: effects)
        }
        catch{
            throw error
        }
    }
    
    
    
    ///Play an audio file from
    func playFile(url: URL, effects: Effects?) throws{
        do{
            
            let audioFile = try AudioFile(forReading: url)
            
            guard let buffer = audioFile.buffer else{
                throw PlayingError.cantScheduleBuffer
            }
            try audioFile.read(into: buffer)
            
            self.audioNodes.audioPlayer.file = audioFile
            self.audioNodes.setEffects(effects: effects)
            
            self.audioNodes.audioEngine.attachAndConnect([
                self.audioNodes.audioPlayer,
                self.audioNodes.pitchAndSpeedNode,
                self.audioNodes.distortionNode,
                self.audioNodes.reverbNode
            ], format: buffer.format)

            if !self.audioNodes.audioEngine.isRunning{
                self.audioNodes.audioEngine.prepare()
                try self.audioNodes.audioEngine.start()
            }
            
            self.audioNodes.audioPlayer.scheduleBuffer(buffer) {
                print("didStop")
                self.delegate?.didPlayerStopPlaying()
            }
            self.audioNodes.audioPlayer.play()
            isPaused = false
        }
        catch{
            throw error
        }
    }
    
    ///Resumes the audioPlayer
    func resume(){
        if isPaused{
            self.audioNodes.audioPlayer.play()
            isPaused = false
        }
    }
    
    ///Pauses the audioPlayer
    func pause(){
        self.audioNodes.audioPlayer.pause()
        isPaused = true
    }
    
    ///Stops the audioPlayer
    func stopPlaying(){
        self.audioNodes.audioPlayer.stop()
    }
    
    ///Set avaudio session playback
    func setPlayback(){
        if AVAudioSession.sharedInstance().category != .playback{
            do{
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.interruptSpokenAudioAndMixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            }
            catch{
                
            }
        }
    }
    
    enum PlayingError: Error{
        case cantScheduleBuffer
    }
}
extension Player.PlayingError: LocalizedError{
    var errorDescription: String?{
        get{
            switch self {
            case .cantScheduleBuffer:
                return "Can't schedule buffer"
            }
        }
    }
}
protocol PlayerDelegate{
    func didPlayerStopPlaying()
}
