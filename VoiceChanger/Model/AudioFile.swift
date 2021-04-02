//
//  AudioFile.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import Foundation
import AVFoundation
///Class for audio file with duration
class AudioFile: AVAudioFile{
    
    ///Returns a frame count of an audio file
    private var frameCount: AVAudioFrameCount{
        get{
            return AVAudioFrameCount(self.length)
        }
    }

    
    func returnRemainingDuration(currentPosition: AVAudioFramePosition) -> AVAudioFrameCount{
        if AVAudioFrameCount(frameCount) > AVAudioFrameCount(currentPosition){
            return AVAudioFrameCount(frameCount - AVAudioFrameCount(currentPosition))
        }
        return AVAudioFrameCount(1)
    }
    
    ///Creates a pcm buffer
    lazy var buffer: AVAudioPCMBuffer? = {
        guard let newBuffer = AVAudioPCMBuffer(pcmFormat: self.processingFormat, frameCapacity: frameCount) else{
            return nil
        }
        try? self.read(into: newBuffer)
        return newBuffer
    }()
    
    ///Returns the duration of the file in seconds
    var duration: Double{
        get{
            return Double(Double(frameCount) / self.processingFormat.sampleRate)
        }
    }
    
}
