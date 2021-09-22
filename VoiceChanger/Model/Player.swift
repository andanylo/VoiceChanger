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
        
        self.pitchAndSpeedNode.rate = soundEffects.currentValues.speed
        self.pitchAndSpeedNode.pitch = soundEffects.currentValues.pitch
        
        
        if soundEffects.distortionPreset != nil{
            self.distortionNode.loadFactoryPreset(soundEffects.distortionPreset!)
        }
        if soundEffects.reverbPreset != nil{
            self.reverbNode.loadFactoryPreset(soundEffects.reverbPreset!)
        }
        self.distortionNode.wetDryMix = soundEffects.currentValues.distortion
        self.reverbNode.wetDryMix = soundEffects.currentValues.reverb
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
    
    ///Apply changes from the transition, or effect value change
    func applyTransitionChanges(effectTransitionPart: EffectPart, effects: Effects){
        switch effectTransitionPart {
        case .speed:
            self.pitchAndSpeedNode.rate = effects.currentValues.speed
        case .pitch:
            self.pitchAndSpeedNode.pitch = effects.currentValues.pitch
        case .distortion:
            self.distortionNode.wetDryMix = effects.currentValues.distortion
        case .reverb:
            self.reverbNode.wetDryMix = effects.currentValues.reverb
        case .volume:
            self.audioPlayer.volume = effects.currentValues.volume
        }
    }
}

///Class that plays an audio file with effects
class Player{
    static var shared = Player()
    
    var audioNodes: AudioNodes!
    
    weak var delegate: PlayerDelegate?
    
    var currentVoiceSound: VoiceSound?
    
    private var playerTimer = CustomTimer(timeInterval: 0.01)
    
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
            
            ///Set up effect transition change configuration to avaudonodes
            if !voiceSound.effects.effectTransitions.isEmpty{
                voiceSound.effects.currentValues.applyTransitionChanges = { [weak self] effectPart in
                    self?.audioNodes.applyTransitionChanges(effectTransitionPart: effectPart, effects: voiceSound.effects)
                }
            }
            
            if !self.audioNodes.audioEngine.isRunning{
                self.audioNodes.audioEngine.prepare()
                try self.audioNodes.audioEngine.start()
            }
            
            ///Adapt to time with transitions
            if !voiceSound.effects.effectTransitions.isEmpty{
               
                EffectPart.allCases.forEach({ effectPart in
                    let value = voiceSound.effects.expectedValue(for: effectPart, at: time.returnSeconds())
                    voiceSound.effects.changeEffect(new: value, effectToChange: effectPart)
                })
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
            currentVoiceSound?.effects.resetEffects()
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
    ///Block that indicates the audio player playback
    func timerBlock(timer: CustomTimer) {
        
        if self.audioNodes.audioEngine.isRunning {
            let currentTime = self.audioNodes.audioPlayer.currentTime
            if currentTime != self.previousValue && currentTime >= 0{
                if currentTime >= self.currentVoiceSound?.duration.returnSeconds() ?? 0.0{
                    self.stopPlaying(isPausing: false)
                }
                
                currentVoiceSound?.effects.effectTransitions.forEach({transition in
                    transition.changeEffect(currentPlayerTime: currentTime, updateInterval: timer.timeInterval)
                })
                
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
