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
            self.distortionNode.wetDryMix = soundEffects.distortion
            self.reverbNode.wetDryMix = soundEffects.reverb
            self.distortionNode.loadFactoryPreset(soundEffects.distortionPreset)
            self.reverbNode.loadFactoryPreset(soundEffects.reverbPreset)
        }
        init(audioEngine: AudioEngine, audioPlayer: AudioPlayerNode, pitchAndSpeedNode: AVAudioUnitTimePitch, distortionNode: AVAudioUnitDistortion, reverbNode: AVAudioUnitReverb) {
            self.audioEngine = audioEngine
            self.audioPlayer = audioPlayer
            self.pitchAndSpeedNode = pitchAndSpeedNode
            self.distortionNode = distortionNode
            self.reverbNode = reverbNode
        }
    }
    
    
    var audioNodes: AudioNodes!
    
    var delegate: PlayerDelegate?
    
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
            
            guard let file = voiceSound.audioFile else{
                throw PlayingError.cantFindFile
            }

            
            if self.audioNodes.audioPlayer.file != voiceSound.audioFile{
                
                self.audioNodes.audioPlayer.file = voiceSound.audioFile
                
                self.audioNodes.audioEngine.attachAndConnect([
                    self.audioNodes.audioPlayer,
                    self.audioNodes.pitchAndSpeedNode,
                    self.audioNodes.distortionNode,
                    self.audioNodes.reverbNode
                ], format: file.processingFormat)
                
                if !self.audioNodes.audioEngine.isRunning{
                    self.audioNodes.audioEngine.prepare()
                    try self.audioNodes.audioEngine.start()
                }
    
            }
            self.audioNodes.setEffects(effects: voiceSound.effects)
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

        playerTimer.pause()
        
        if !isPausing{
            playerTimer.reset()
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
    
    enum PlayingError: Error{
        case cantFindFile
    }
    
    private var previousValue: Double = 0.0
}
extension Player: CustomTimerDelegate{
    ///Stop the player if current time is greater than duration
    func timerBlock(timer: CustomTimer) {
        if self.audioNodes.audioEngine.isRunning {
            let currentTime = self.audioNodes.audioPlayer.currentTime
            if currentTime != previousValue && currentTime >= 0{
                if currentTime >= self.currentVoiceSound?.duration.returnSeconds() ?? 0.0{
                    stopPlaying(isPausing: false)
                }
                
                delegate?.didUpdateCurrentTime(currentTime: TimeComponents(seconds: currentTime))
                previousValue = currentTime
            }
        }
    }
}

extension Player.PlayingError: LocalizedError{
    var errorDescription: String?{
        get{
            switch self {
            case .cantFindFile:
                return "Can't find file"
            }
        }
    }
}
protocol PlayerDelegate{
    func didPlayerStopPlaying()
    func didPlayerStartPlaying()
    func didUpdateCurrentTime(currentTime: TimeComponents)
}
