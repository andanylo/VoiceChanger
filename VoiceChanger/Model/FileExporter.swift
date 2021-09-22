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
    
    //TODO:
    //Think about optimizing the frame count
    ///Count the frames with effect transitions
    private func frameCount(file: AudioFile, effects: Effects, processFrameCount: UInt32) -> UInt32{
        var speedTransitions = effects.effectTransitions.filter({$0.effectPartToTransition == .speed})
        
        if !speedTransitions.isEmpty{
            speedTransitions.sort(by: {$0.startPointFrames < $1.startPointFrames})
            var duration: UInt32 = 0
            for i in 0..<speedTransitions.count{
                if i == 0{
                    duration += UInt32(Double(speedTransitions[i].startPointFrames) / Double(effects.standardValues.speed))
                }
                if i == speedTransitions.count - 1{
                    duration += UInt32(Double(file.frameCount - speedTransitions[i].endPointFrames) / Double(speedTransitions[i].transitionValue))
                }
                else if i != 0{
                    duration += UInt32(Double(speedTransitions[i].startPointFrames - speedTransitions[i-1].endPointFrames) / Double(speedTransitions[i-1].transitionValue))
                }
                duration += speedTransitions[i].duration(processFrameCount: processFrameCount)
            }
            return duration
        }
        return UInt32(Float(file.frameCount) / effects.standardValues.speed)
    }
    
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
        let maxNumberOfFrames: AVAudioFrameCount = 64
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
        
        let fileLength = Int64(frameCount(file: file, effects: voiceSound.effects, processFrameCount: maxNumberOfFrames))
        //Set transition change block
        if !voiceSound.effects.effectTransitions.isEmpty{
            voiceSound.effects.currentValues.applyTransitionChanges = { [weak self] effectPart in
                
                self?.exportAudioNodes.applyTransitionChanges(effectTransitionPart: effectPart, effects: voiceSound.effects)
            }
        }
        
        var renderCurrentFrame: Double = 0.0
        while exportAudioNodes.audioEngine.manualRenderingSampleTime < fileLength{
            
            voiceSound.effects.effectTransitions.forEach({transition in
                transition.changeEffect(currentFrame: AVAudioFramePosition(renderCurrentFrame), updateInterval: maxNumberOfFrames)
            })
            renderCurrentFrame += Double(maxNumberOfFrames) * Double(voiceSound.effects.currentValues.speed)
            
            let status = try exportAudioNodes.audioEngine.renderOffline(buffer.frameCapacity, to: buffer)
            
            switch status{
            case .success:
                try newAudioFile.write(from: buffer)
                
            default:
                break
            }
        }
        completion(exportURL)
        voiceSound.effects.resetEffects()
        exportAudioNodes.audioPlayer.stop()
        exportAudioNodes.audioEngine.disableManualRenderingMode()
        exportAudioNodes.audioEngine.stop()
    }
}
