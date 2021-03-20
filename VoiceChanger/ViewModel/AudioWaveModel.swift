//
//  AudioWaveModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation
import UIKit

///Model view for audio wave
class AudioWaveModel{
    
    var numberOfTiles: Int = 0
    var refreshInterval: TimeInterval = 0.0
    var refreshCounter: Double = 0.0
    
    var heightArray: [CGFloat] = []
    init(numberOfTiles: Int, refreshInterval: TimeInterval){
        self.numberOfTiles = numberOfTiles
        self.refreshInterval = refreshInterval
        reset()
    }
    
    ///Resets the height array
    func reset(){
        heightArray = [CGFloat].init(repeating: 5, count: numberOfTiles)
    }
    
    ///Converts the power of audio record to the height of tile
    func convertPowerToHeightTile(viewHeight: CGFloat, power: Float) -> CGFloat{
        let maximum: Float = 120
        let positivePower: Float = maximum + power
        let percentage = positivePower / maximum
        
        let minimumHeight: Float = 5
        let maximumHeight: Float = Float(viewHeight)
        
        return CGFloat(max(percentage * maximumHeight, minimumHeight))
    }
    
    ///Update heights array for each tile
    func updateHeights(newHeight: CGFloat){
        heightArray.append(newHeight)
        heightArray.removeFirst()
    }
}
