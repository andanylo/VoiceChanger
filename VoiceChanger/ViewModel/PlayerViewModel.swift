//
//  PlayerViewModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 26.03.2021.
//

import Foundation
class PlayerViewModel{
    var voiceSound: VoiceSound?
    
    var onPlayStateChange: ((Bool) -> Void)?
    
    ///Method that handles whenever the
    func didClickOnPlayButton(){
        guard let voiceSound = voiceSound else{
            return
        }
        
        var isPlaying = Player.shared.playerState.isPlaying(for: voiceSound)
        if !isPlaying{
            do{
                try Player.shared.playFile(voiceSound: voiceSound)
            }
            catch{
                
            }
        }
        else{
            if !Player.shared.playerState.isPaused{
                Player.shared.pause()
            }
        }
        isPlaying = Player.shared.playerState.isPlaying(for: voiceSound)
        
        onPlayStateChange?(isPlaying)
    }
    
    ///Returns the slider value converted from TimeComponents
    func returnSliderValue(current components: TimeComponents) -> Float{
        return Float(components.returnCombinedMiliseconds())
    }
    
    var sliderComponents: TimeComponents = TimeComponents(){
        didSet{
            let durationSeconds: Double = voiceSound?.duration.returnSeconds() ?? 0
            let sliderSeconds: Double = sliderComponents.returnSeconds()
            remainingComponents.convertFromSeconds(seconds: durationSeconds - sliderSeconds)
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
