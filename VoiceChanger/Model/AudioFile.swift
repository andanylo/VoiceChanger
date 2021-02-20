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
    
    ///Returns the duration of the file in seconds
    var duration: Double{
        get{
            let audioNodeFileLength = AVAudioFrameCount(self.length)
            return Double(Double(audioNodeFileLength) / self.processingFormat.sampleRate)
        }
    }
    
}
