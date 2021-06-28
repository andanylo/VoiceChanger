//
//  FileExporter.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 06.05.2021.
//

import Foundation
import AVFoundation

class FileExporter{
    static var shared = FileExporter()
    
    lazy var exportAudioNodes: AudioNodes = {
       return AudioNodes(audioEngine: AudioEngine(), audioPlayer: AudioPlayerNode(), pitchAndSpeedNode: AVAudioUnitTimePitch(), distortionNode: AVAudioUnitDistortion(), reverbNode: AVAudioUnitReverb())
    }()
    
    ///Creates and exports an audioFile with effects
    func exportFile(voiceSound: VoiceSound, completion: @escaping ((URL) -> Void)) throws{
        
        //Set up effects and nodes
        try exportAudioNodes.setUp(voiceSound: voiceSound)

        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first, let file = exportAudioNodes.audioPlayer.file else{
            return
        }
        
        //Schedule file
        self.exportAudioNodes.audioPlayer.scheduleFile(file, at: nil, completionHandler: nil)
        //Enable manual rendering mode
        let maxNumberOfFrames: AVAudioFrameCount = 4
        try exportAudioNodes.audioEngine.enableManualRenderingMode(.offline, format: file.processingFormat, maximumFrameCount: maxNumberOfFrames)
        
        //Start engine
        if !self.exportAudioNodes.audioEngine.isRunning{
            self.exportAudioNodes.audioEngine.prepare()
            try self.exportAudioNodes.audioEngine.start()
        }
        //Start file
        self.exportAudioNodes.audioPlayer.play()
        
        let exportURL = cacheURL.appendingPathComponent(voiceSound.name + ".m4a")
        let newAudioFile = try AVAudioFile(forWriting: exportURL, settings: file.fileFormat.settings)
       
        //Buffer from manual renderer
        let buffer: AVAudioPCMBuffer = AVAudioPCMBuffer(pcmFormat: exportAudioNodes.audioEngine.manualRenderingFormat, frameCapacity: exportAudioNodes.audioEngine.manualRenderingMaximumFrameCount)!
        
        var fileLength = Int64(Float(file.length) / exportAudioNodes.pitchAndSpeedNode.rate)
        
        //Set transition change block
        if !voiceSound.effects.effectTransitions.isEmpty{
            voiceSound.effects.applyTransitionChanges = { [weak self] effectPart in
                self?.exportAudioNodes.applyTransitionChanges(effectTransitionPart: effectPart, effects: voiceSound.effects)
            }
        }
        
        while exportAudioNodes.audioEngine.manualRenderingSampleTime < fileLength{
            let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(fileLength - exportAudioNodes.audioEngine.manualRenderingSampleTime))
            
            voiceSound.effects.effectTransitions.forEach({transition in
                transition.changeEffect(currentFrame: exportAudioNodes.audioEngine.manualRenderingSampleTime, updateInterval: maxNumberOfFrames)
            })
            
           
            fileLength = Int64(Float(file.length) / exportAudioNodes.pitchAndSpeedNode.rate)
            
            let status = try exportAudioNodes.audioEngine.renderOffline(framesToRender, to: buffer)
            
            switch status{
            case .success:
                try newAudioFile.write(from: buffer)
            default:
                break
            }
        }
        completion(exportURL)
        exportAudioNodes.audioPlayer.stop()
        exportAudioNodes.audioEngine.stop()
    }
}
