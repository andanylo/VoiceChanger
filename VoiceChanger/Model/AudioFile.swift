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
    var frameCount: AVAudioFrameCount{
        get{
            guard let bufferLength = self.buffer?.frameLength else{
                return AVAudioFrameCount(self.length)
            }
            return AVAudioFrameCount(bufferLength)
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
        guard let newBuffer = AVAudioPCMBuffer(pcmFormat: self.processingFormat, frameCapacity: AVAudioFrameCount(self.length)) else{
            return nil
        }
        try? self.read(into: newBuffer)
        return newBuffer
    }()
    
    ///Returns the duration of the file in seconds
    var duration: Double{
        get{
            guard let buffer = buffer else {
                return Double(Double(self.length) / self.processingFormat.sampleRate)
            }
            return Double(Double(frameCount) / buffer.format.sampleRate)
            
        }
    }
    
}
