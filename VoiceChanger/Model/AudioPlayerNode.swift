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
    
    ///Seconds from what player should start
    private var startSeconds: Double = 0.0
    
    ///Returns the current time of audio player node
    var currentTime: Double{
        get{
            if let nodeTime: AVAudioTime = self.lastRenderTime, let playerTime: AVAudioTime = self.playerTime(forNodeTime: nodeTime) {
                return startSeconds + Double(playerTime.sampleTime) / playerTime.sampleRate
            }
            return startSeconds
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
    
    ///Play from start components
    func play(from startComponents: TimeComponents) throws{
        guard let file = self.file else{
            return
        }
        self.startSeconds = startComponents.returnSeconds()
        let position = AVAudioFramePosition(self.startSeconds * self.outputFormat(forBus: 0).sampleRate)
        self.scheduleSegment(file, startingFrame: position, frameCount: file.returnRemainingDuration(currentPosition: position), at: nil, completionHandler: nil)

        super.play()
    }
    
    override func stop() {
        super.stop()
        self.startSeconds = 0.0
    }
    
    enum PlayerNodeError: Error{
        case fileNotExists
    }
}
