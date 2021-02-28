//
//  AudioPlayerNode.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import Foundation
import AVFoundation


class AudioPlayerNode: AVAudioPlayerNode{
    
    var file: AudioFile?
    
    ///Returns the duration of audio file
    var duration: Double{
        get{
            guard let file = self.file else{
                return 0.0
            }
            return file.duration
        }
    }
    
    ///Returns the current time of audio player node
    var currentTime: Double{
        get{
            if let nodeTime: AVAudioTime = self.lastRenderTime, let playerTime: AVAudioTime = self.playerTime(forNodeTime: nodeTime) {
                return Double(playerTime.sampleTime) / playerTime.sampleRate
            }
            return 0.0
        }
    }
    
    ///Initializtion of an object with an audio file as a parameter
    init(file: AudioFile){
        super.init()
        self.file = file
    }
    
    override init(){
        super.init()
    }
}
