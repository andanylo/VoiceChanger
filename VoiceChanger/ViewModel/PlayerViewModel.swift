//
//  PlayerViewModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 26.03.2021.
//

import Foundation
import UIKit
class PlayerViewModel{
    var voiceSound: VoiceSound?
    
    var onPlayStateChange: ((Bool) -> Void)?
    
    var onPlayerCurrentTimeChange: ((TimeComponents) -> Void)?
    
    var onSliderComponentChange: (() -> Void)?
    
    var onClickOptionsButton: (() -> Void)?
    
    ///Method that handles whenever the
    func didClickOnPlayButton(){
        guard let voiceSound = voiceSound else{
            return
        }
        
        ///If other sound is currently playing, stop it
        if Player.shared.currentVoiceSound?.playerState.isPlaying == true && Player.shared.currentVoiceSound?.fullPath != voiceSound.fullPath{
            Player.shared.stopPlaying(isPausing: false)
        }
     
        if !voiceSound.playerState.isPlaying{
            do{
                try Player.shared.playFile(voiceSound: voiceSound, at: sliderComponents)
            }
            catch{
                
            }
        }
        else{
            Player.shared.stopPlaying(isPausing: true)
        }
    }
    
    ///Method that gets called on skip button click
    func didClickOnSkipButton(typeOfSkipButton: PlayerView.SkipButtonType){
        let wasPlaying = Player.shared.currentVoiceSound?.playerState.isPlaying
        if Player.shared.currentVoiceSound?.playerState.isPlaying == true{
            Player.shared.stopPlaying(isPausing: true)
        }
        
        if typeOfSkipButton == .forward{
            updateSliderComponents(seconds: min(sliderSeconds + 5, voiceSound?.duration.returnSeconds() ?? 0))
        }
        else{
            updateSliderComponents(seconds: max(sliderSeconds - 5, 0))
        }
        
        if let voiceSound = voiceSound, wasPlaying == true{
            try? Player.shared.playFile(voiceSound: voiceSound, at: sliderComponents)
        }
    }
    

    
    ///Method that gets called after slider has changed it's value
    func didChangeTheValueOfSlider(value: Float){
        updateSliderComponents(sliderValue: value)
        
        let isPlaying = Player.shared.currentVoiceSound?.playerState.isPlaying
        if isPlaying == true{
            Player.shared.stopPlaying(isPausing: true)
        }
    }
    
    ///Method that gets called after touch was removed from slider
    func didRemoveTouchFromSlider(){
        guard let voiceSound = voiceSound else{
            return
        }
        try? Player.shared.playFile(voiceSound: voiceSound, at: sliderComponents)
    }
    
    ///Returns the slider value converted from TimeComponents
    func returnSliderValue(current components: TimeComponents) -> Float{
        return Float(components.returnCombinedMiliseconds())
    }
    
    private var sliderSeconds: Double = 0.0
    
    var sliderComponents: TimeComponents = TimeComponents(){
        didSet{
            let durationSeconds: Double = voiceSound?.duration.returnSeconds() ?? 0
            sliderSeconds = sliderComponents.returnSeconds()
            remainingComponents.convertFromSeconds(seconds: durationSeconds - sliderSeconds)
            
            onSliderComponentChange?()
        }
    }
    var remainingComponents: TimeComponents = TimeComponents()
    
    ///updates the slider components
    func updateSliderComponents(sliderValue: Float){
        let sliderValueInt = Int(sliderValue)
        sliderComponents.convertFromMiliseconds(miliseconds: sliderValueInt)
    }
    
    ///updates the slider components
    func updateSliderComponents(seconds: Double){
        sliderComponents.convertFromSeconds(seconds: seconds)
    }
    
    init(voiceSound: VoiceSound){
        self.voiceSound = voiceSound
        self.remainingComponents = voiceSound.duration
    }
}

