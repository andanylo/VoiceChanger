//
//  VoiceSoundCellModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 17.03.2021.
//

import Foundation
import UIKit

class VoiceSoundCellModel{
    var voiceSound: VoiceSound?{
        didSet{
            if voiceSound != nil{
                setPlayerViewModel(voiceSound: voiceSound!)
            }
        }
    }
    
    var playerViewModel: PlayerViewModel?{
        didSet{
            self.playerViewModel?.onClickOptionsButton = {
                self.presentOptions()
            }
        }
    }
    
    ///Returns the name of the cell
    var name: String?{
        get{
            return voiceSound?.name
        }
    }
    
    weak var listViewController: ListViewController?
    
    ///Height of the cell
    var defaultHeight: CGFloat = 100//50
    var expandedHeight: CGFloat{
        get{
            return defaultHeight * 4
        }
    }
    private var _height: CGFloat = 0.0
    var height: CGFloat{
        set(value){
            self._height = value
        }
        get{
            return isSelected == true ? expandedHeight : defaultHeight
        }
    }
    
    ///Area for cell
    var edges = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    ///Is currently selected
    var isSelected: Bool = false{
        didSet{
            didSelect?(self.isSelected)
        }
    }
    
    ///On selection state change
    var didSelect: ((Bool) -> Void)?
    
    func setPlayerViewModel(voiceSound: VoiceSound){
        self.playerViewModel = PlayerViewModel(voiceSound: voiceSound)
        self.playerViewModel?.onClickOptionsButton = {
            self.presentOptions()
        }
        self.playerViewModel?.onEffectCreate = {
            self.presentEffectCreator()
        }
    }
    
    init(voiceSound: VoiceSound?, listViewController: ListViewController?){
        self.voiceSound = voiceSound
        self.height = defaultHeight
        self.listViewController = listViewController
        if self.playerViewModel == nil && voiceSound != nil{
            setPlayerViewModel(voiceSound: voiceSound!)
        }
    }
    
    ///Remove the cell
    func didRemoveButtonClicked(cell: VoiceSoundCell?){
        guard let cell = cell else{
            return
        }
        self.listViewController?.collectionViewDeleteAction(cell: cell)
    }
    
    ///tell the view controller to present options of sound
    func presentOptions(){
        guard let voiceSound = voiceSound else{
            return
        }
        DispatchQueue.main.async {
            self.listViewController?.presentOptions(voiceSound: voiceSound)
        }
    }
    
    ///tell the view controller to present effect creator
    func presentEffectCreator(){
        DispatchQueue.main.async {
            self.listViewController?.presentEffectCreator()
        }
    }
    
    ///Changes selected and tells the view controller
    func changeSelected(){
        self.isSelected = isSelected == false ? true : false
        DispatchQueue.main.async {
            self.listViewController?.changeSelected(voiceSoundCellModel: self)
        }
    }
}
