//
//  AudioEngine.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 24.02.2021.
//

import Foundation
import AVFoundation

///Class that extends the audioEngine
class AudioEngine: AVAudioEngine{
    
    ///Connect and attach nodes to audio engine
    func attachAndConnect(_ nodes: [AVAudioNode], format: AVAudioFormat) {
        let attached = nodes.contains(where: {$0.engine == nil})
        if attached{
            for i in nodes{
                if i.engine == nil{
                    self.attach(i)
                }
            }
            
            if nodes.count > 1 {
                for i in 0..<nodes.count - 1{
                    self.connect(nodes[i], to: nodes[i+1], format: format)
                }
            }
            self.connect(nodes.last!, to: self.mainMixerNode, format: format)
        }
    }
    
    
}
