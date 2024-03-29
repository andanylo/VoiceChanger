//
//  EffectPointer.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 22.06.2021.
//

import Foundation
import AVFoundation

///EffectTransition class that is placed to change the effect over time
class EffectTransition{
    
    ///Returns the duration of the file
    var fileDuration: (() -> TimeComponents)?
    
    ///Returns the duration of the file in frames
    var fileDurationFrames: (() -> AVAudioFrameCount)?
    
    ///Composition relation, effect pointer can't exist withot an effect
    unowned var effect: Effects!
    
    ///Effect part to change
    var effectPartToTransition: EffectPart!
    
    ///Start point of the transition
    private var startPoint: EffectPoint!
    
    ///End point of the transition
    private var endPoint: EffectPoint!
    
    ///Start point in seconds
    var startPointSeconds: Double{
        get{
            return pointInSeconds(point: startPoint)
        }
    }
    
    ///End point in seconds
    var endPointSeconds: Double{
        get{
            return pointInSeconds(point: endPoint)
        }
    }
    
    ///Start point in frames
    var startPointFrames: AVAudioFrameCount{
        get{
            return pointInFrames(point: startPoint)
        }
    }
    
    ///End point in frames
    var endPointFrames: AVAudioFrameCount{
        get{
            return pointInFrames(point: endPoint)
        }
    }

    ///point of transition in seconds
    func pointInSeconds(point: EffectPoint) -> Double{
        guard let duration = fileDuration?() else{
            return 0.0
        }
        
        return point.value * duration.returnSeconds()
    }
    
    ///point of transition in frames
    func pointInFrames(point: EffectPoint) -> AVAudioFrameCount{
        guard let duration = fileDurationFrames?() else{
            return AVAudioFrameCount(0)
        }
        return AVAudioFrameCount(point.value * Double(duration))
    }
    
    ///Transition value
    var transitionValue: Float = 0.0
    
    ///Transition process
    var isTransitioning = false
    
    ///Initialize with effects, to which this class relates to
    init(effects: Effects, startPoint: EffectPoint, endPoint: EffectPoint, fromValue: Float, transitionValue: Float, effectPartToTransition: EffectPart){
        self.effect = effects
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.transitionValue = transitionValue
        self.effectPartToTransition = effectPartToTransition
        self._startEffectValue = fromValue
    }
    
    
    private var _startEffectValue: Float = 0.0
    
    ///Returns the value from effect to change
    private func returnEffectValueToChange() -> Float{
        switch effectPartToTransition {
        case .speed:
            return effect.currentValues.speed
        case .pitch:
            return effect.currentValues.pitch
        case .distortion:
            return effect.currentValues.distortion
        case .reverb:
            return effect.currentValues.reverb
        case .volume:
            return effect.currentValues.volume
        case .none:
            return 0.0
        }
    }
    
    
    ///Duration of the transition in frames
    func duration(processFrameCount: UInt32) -> UInt32{
        if effectPartToTransition == .speed{
            effect.resetEffects()
            var effectValue = _startEffectValue

            let difference = endPointFrames - startPointFrames
            let intervals = difference / processFrameCount
            
            let valuePerInterval = calculateValuePerInterval(updateInterval: Double(processFrameCount), startTime: Double(startPointFrames), endTime: Double(endPointFrames))
            
            var duration: Double = 0.0
            for _ in 0..<intervals{
                effectValue += valuePerInterval
                duration += Double(processFrameCount) / Double(effectValue)
            }
            return UInt32(duration)
        }
        return endPointFrames - startPointFrames
    }
    
    ///Transition effect by update interval in seconds, during playing in player
    func changeEffect(currentPlayerTime: Double, updateInterval: Double){

        let currentRoundedSpeed = Float(returnEffectValueToChange() * 100).rounded() / 100
        let transitionRoundedValue = Float(transitionValue * 100).rounded() / 100
        

        if currentPlayerTime >= startPointSeconds && currentRoundedSpeed != transitionRoundedValue{
            self.isTransitioning = true
        }
        else{
            self.isTransitioning = false
        }
        
        if self.isTransitioning{
            let expectedValue = expectedValue(updateInterval: updateInterval, currentPlayerTime: currentPlayerTime)
            
            if currentRoundedSpeed != expectedValue{
                applyChanges(new: expectedValue)
            }
        }
    }
    
    func expectedValue(updateInterval: Double, currentPlayerTime: Double) -> Float{
        let valuePerInterval = calculateValuePerInterval(updateInterval: updateInterval, startTime: startPointSeconds, endTime: endPointSeconds)
      
        return expectedValueAt(seconds: currentPlayerTime, valuePerInterval: valuePerInterval, timeInterval: updateInterval)
    }
    
    ///Expected value at specific seconds
    private func expectedValueAt(seconds: Double, valuePerInterval: Float, timeInterval: Double) -> Float{
        let difference: Float = Float(seconds - startPointSeconds)
        let intervals = difference / Float(timeInterval)
        let rounded = Float(intervals * valuePerInterval * 100).rounded() / 100
        return valuePerInterval >= 0 ? min(_startEffectValue + rounded, transitionValue) : max(_startEffectValue + rounded, transitionValue)
    }
    
    ///Expected value at specific seconds
    private func expectedValueAt(framePosition: AVAudioFramePosition, valuePerInterval: Float, timeInterval: UInt32) -> Float{
        let difference = framePosition - Int64(startPointFrames)
        let intervals = difference / Int64(timeInterval)
        let rounded = (Double(intervals) * Double(valuePerInterval) * 100).rounded() / 100
        return valuePerInterval >= 0 ? min(_startEffectValue + Float(rounded), transitionValue) : max(_startEffectValue + Float(rounded), transitionValue)
    }
    
    ///Calculate value per interval
    private func calculateValuePerInterval(updateInterval: Double, startTime: Double, endTime: Double) -> Float{
        let timeDifference = endTime - startTime
        let effectDifference = transitionValue - _startEffectValue
        let ratio = timeDifference / updateInterval
        return effectDifference / Float(ratio)
    }
    
    ///Transition effect by update interval in seconds, during proccessing the file
    func changeEffect(currentFrame: AVAudioFramePosition, updateInterval: UInt32){
        let currentRoundedSpeed = Float(returnEffectValueToChange() * 100).rounded() / 100
        let transitionRoundedValue = Float(transitionValue * 100).rounded() / 100
        
        if currentFrame >= startPointFrames && currentRoundedSpeed != transitionRoundedValue{
            self.isTransitioning = true
        }
        else{
            self.isTransitioning = false
        }
        if self.isTransitioning{
            let valuePerInterval = calculateValuePerInterval(updateInterval: Double(updateInterval), startTime: Double(startPointFrames), endTime: Double(endPointFrames))
            
            let expectedValue = expectedValueAt(framePosition: currentFrame, valuePerInterval: valuePerInterval, timeInterval: updateInterval)
            
            if currentRoundedSpeed != expectedValue{
                applyChanges(new: expectedValue)
            }
        }
        
        
    }
    
    ///apply changes to the effect
    private func applyChanges(new value: Float){
        self.effect.changeEffect(new: value, effectToChange: effectPartToTransition)
    }
    
    ///Point enumeration
    enum EffectPoint{
        
        case half
        case lastQuarter
        case firstQuarter
        case zero
        case end
        case custom(Double)
        
        ///Converts the case to double
        var value: Double{
            get{
                switch self{
                case .half:
                    return 0.5
                case .firstQuarter:
                    return 0.25
                case .lastQuarter:
                    return 0.75
                case .zero:
                    return 0.0
                case .end:
                    return 1
                case .custom(let customValue):
                    return customValue
                }
            }
        }
    }
    
}

