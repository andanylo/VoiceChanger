//
//  Player.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 20.02.2021.
//

import Foundation
import AVFoundation

///Class that has all audio nodes
class AudioNodes{
    var audioEngine: AudioEngine
    var audioPlayer: AudioPlayerNode
    var pitchAndSpeedNode: AVAudioUnitTimePitch
    var distortionNode: AVAudioUnitDistortion
    var reverbNode: AVAudioUnitReverb

    func setEffects(effects: Effects?){
        let soundEffects = effects ?? Effects()
        
        self.pitchAndSpeedNode.rate = soundEffects.speed
        self.pitchAndSpeedNode.pitch = soundEffects.pitch

        
        
        if soundEffects.distortionPreset != nil{
            self.distortionNode.loadFactoryPreset(soundEffects.distortionPreset!)
        }
        if soundEffects.reverbPreset != nil{
            self.reverbNode.loadFactoryPreset(soundEffects.reverbPreset!)
        }
        self.distortionNode.wetDryMix = soundEffects.distortion
        self.reverbNode.wetDryMix = soundEffects.reverb
    }
    init(audioEngine: AudioEngine, audioPlayer: AudioPlayerNode, pitchAndSpeedNode: AVAudioUnitTimePitch, distortionNode: AVAudioUnitDistortion, reverbNode: AVAudioUnitReverb) {
        self.audioEngine = audioEngine
        self.audioPlayer = audioPlayer
        self.pitchAndSpeedNode = pitchAndSpeedNode
        self.distortionNode = distortionNode
        self.reverbNode = reverbNode
    }
    func setUp(voiceSound: VoiceSound) throws{
        guard let file = voiceSound.audioFile else{
            throw PlayingError.cantFindFile
        }
        
        if audioPlayer.file != file{
            
            audioPlayer.file = file
            
            audioEngine.attachAndConnect([
                audioPlayer,
                pitchAndSpeedNode,
                distortionNode,
                reverbNode
            ], format: file.processingFormat)
        }
        setEffects(effects: voiceSound.effects)
    }
}

///Class that plays an audio file with effects
class Player{
    static var shared = Player()
    
    var audioNodes: AudioNodes!
    
    weak var delegate: PlayerDelegate?
    
    var currentVoiceSound: VoiceSound?
    
    private var playerTimer = CustomTimer(timeInterval: 0.001)
    
    ///Initializtion that initiates an audio engine
    init(){
        self.audioNodes = AudioNodes(audioEngine: AudioEngine(), audioPlayer: AudioPlayerNode(), pitchAndSpeedNode: AVAudioUnitTimePitch(), distortionNode: AVAudioUnitDistortion(), reverbNode: AVAudioUnitReverb())
        self.playerTimer.delegate = self
    }

    
    
    
    ///Play an audio file from voice sound class
    func playFile(voiceSound: VoiceSound, at time: TimeComponents) throws{
        do{
            
            Player.shared.setPlayback()

            try self.audioNodes.setUp(voiceSound: voiceSound)
            
            if !self.audioNodes.audioEngine.isRunning{
                self.audioNodes.audioEngine.prepare()
                try self.audioNodes.audioEngine.start()
            }
            
            try self.audioNodes.audioPlayer.play(from: time)
            
            self.currentVoiceSound = voiceSound
            self.currentVoiceSound?.playerState.isPlaying = true
            
            playerTimer.setCurrentTime(from: time)
            playerTimer.start()
            
            self.delegate?.didPlayerStartPlaying()
        }
        catch{
            throw error
        }
    }
    
    ///Method that executes after the player stopped playing
    private func didStop(isPausing: Bool){
        if !isPausing{
            playerTimer.reset()
        }
        else{
            playerTimer.pause()
        }
        
        currentVoiceSound?.playerState.reset()
        
        delegate?.didPlayerStopPlaying()
        if !isPausing{
            currentVoiceSound = nil
        }
    }
    
    ///Stops the audioPlayer
    func stopPlaying(isPausing: Bool){
        
        if Player.shared.audioNodes.audioEngine.isRunning{
            if currentVoiceSound?.playerState.isPlaying == true{
                self.audioNodes.audioPlayer.stop()
            }
            didStop(isPausing: isPausing)
        }
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
    
    private var previousValue: Double = 0.0
}
extension Player: CustomTimerDelegate{
    ///Stop the player if current time is greater than duration
    func timerBlock(timer: CustomTimer) {
        
        if self.audioNodes.audioEngine.isRunning {
            let currentTime = self.audioNodes.audioPlayer.currentTime
            if currentTime != self.previousValue && currentTime >= 0{
                if currentTime >= self.currentVoiceSound?.duration.returnSeconds() ?? 0.0{
                    self.stopPlaying(isPausing: false)
                }
                
                self.delegate?.didUpdateCurrentTime(currentTime: TimeComponents(seconds: currentTime))
                self.previousValue = currentTime
            }
        }
        
    }
}

extension PlayingError: LocalizedError{
    var errorDescription: String?{
        get{
            switch self {
            case .cantFindFile:
                return "Can't find file"
            }
        }
    }
}
protocol PlayerDelegate: AnyObject{
    func didPlayerStopPlaying()
    func didPlayerStartPlaying()
    func didUpdateCurrentTime(currentTime: TimeComponents)
}
enum PlayingError: Error{
    case cantFindFile
}
