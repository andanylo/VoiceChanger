//
//  AudioWave.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation
import UIKit

///Class that indicats the db of audio recorder
class RecorderAudioWave: UIView{
    var safeArea: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    private var tiles: [AudioWaveShapeLayer] = []
    var spacing: CGFloat? = 0
    var tileWidth: CGFloat? = 0
    var tileColor: UIColor = .red
    
    var audioWaveModel: AudioWaveModel!
    
    init(spacing: CGFloat?, tileWidth: CGFloat?, audioWaveModel: AudioWaveModel){
        super.init(frame: CGRect.zero)
        self.spacing = spacing
        self.tileWidth = tileWidth
        self.audioWaveModel = audioWaveModel
        createTiles()
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
    }
    
    ///Creates the tiles and adds to the layer
    func createTiles(){
        if tiles.isEmpty{
            for _ in 0..<audioWaveModel.numberOfTiles{
                let tile = AudioWaveShapeLayer()
                tile.frame = CGRect.zero
                tile.backgroundColor = tileColor.cgColor
                tile.fillColor = tileColor.cgColor
                self.tiles.append(tile)
            }
            for tile in tiles{
                self.layer.addSublayer(tile)
            }
        }
    }
    
    ///Layout Tiles, set width, spacing and poition for them
    func layoutTiles(){
        let numberOfSpaces = tiles.count - 1
        let widthOfView = self.frame.width - CGFloat(safeArea.right) - CGFloat(safeArea.left)
        
        let spacing = max(0, self.spacing == nil ? ((widthOfView - (self.tileWidth! * CGFloat(tiles.count))) / CGFloat(numberOfSpaces)) : self.spacing!)
        
        var width = max(0.5, self.tileWidth == nil ? ((widthOfView - (spacing * CGFloat(numberOfSpaces))) /  CGFloat(tiles.count)) : self.tileWidth!)
        
        if (width * CGFloat(tiles.count))  > widthOfView{
            width = widthOfView / CGFloat(tiles.count)
        }
        
        var pointX = safeArea.left
        for numberTile in 0..<tiles.count{
            
            let previousTile: AudioWaveShapeLayer? = numberTile == 0 ? nil : tiles[numberTile - 1]
            let currentTile: AudioWaveShapeLayer = self.tiles[numberTile]
            
            pointX = previousTile == nil ? safeArea.left : (pointX + width + spacing)
            let pointY = safeArea.top + self.frame.height / 2 - self.audioWaveModel.heightArray[numberTile] / 2
           
            currentTile.setPath(pointX: pointX, pointY: pointY, width: width, height: self.audioWaveModel.heightArray[numberTile])
        }
    }
    
    ///Update  tiles height
    func update(timer: CustomTimer, recorder: Recorder){
        self.audioWaveModel.refreshCounter += timer.timeInterval
        if self.audioWaveModel.refreshCounter >= self.audioWaveModel.refreshInterval{
            
            let height = self.audioWaveModel.convertPowerToHeightTile(viewHeight: self.frame.height - self.safeArea.top - self.safeArea.bottom, power: recorder.averagePower())
            
            self.audioWaveModel.updateHeights(newHeight: height)
            
            for numberTile in 0..<tiles.count{
                
                let currentTile: AudioWaveShapeLayer = self.tiles[numberTile]
                let height = self.audioWaveModel.heightArray[numberTile]
                
                currentTile.setPath(pointX: currentTile.pointX, pointY: safeArea.top + self.frame.height / 2 - height / 2, width: currentTile.width, height: height)
            }
            
            self.audioWaveModel.refreshCounter = 0
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTiles()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

///Audio wave shape layer that saves the values of path
class AudioWaveShapeLayer: CAShapeLayer{
    var pointX: CGFloat = 0
    var pointY: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    func setPath(pointX: CGFloat, pointY: CGFloat, width: CGFloat, height: CGFloat){
        self.pointX = pointX
        self.pointY = pointY
        self.width = width
        self.height = height
        
        let path = UIBezierPath(roundedRect: CGRect(x: pointX, y: pointY, width: width, height: height), cornerRadius: width / 2)
        self.path = path.cgPath
        self.setNeedsLayout()
    }
}
