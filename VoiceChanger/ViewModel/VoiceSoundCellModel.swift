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
                setEffectPickerViewModel(voiceSound: voiceSound!)
            }
        }
    }
    
    var playerViewModel: PlayerViewModel?
    
    var effectPickerViewModel: EffectPickerViewModel?
    
    
    
    ///Returns the name of the cell
    var name: String?{
        get{
            return voiceSound?.name
        }
    }
    
    weak var listViewController: ListViewController?
    
    ///Width of the cell
    var width: CGFloat?{
        get{
            guard let width = listViewController?.view.frame.width, let numberInLine = listViewController?.numberOfItemsInLine() else{
                return nil
            }
            return (width / CGFloat(numberInLine)) - edges.left - edges.right
        }
    }
    
    ///Height of the cell
    let defaultHeight: CGFloat = 60
    var expandedHeight: CGFloat{
        get{
            return 210
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
    var edges = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    ///Is currently selected
    var isSelected: Bool = false{
        didSet{
            didSelect?(self.isSelected)
        }
    }
    
    ///On selection state change
    var didSelect: ((Bool) -> Void)?
    
    ///Set player view model
    func setPlayerViewModel(voiceSound: VoiceSound){
        self.playerViewModel = PlayerViewModel(voiceSound: voiceSound)
        self.playerViewModel?.onClickOptionsButton = { [weak self] in
            self?.presentOptions()
        }
    }
    
    ///Set effect picker view model
    func setEffectPickerViewModel(voiceSound: VoiceSound){
        self.effectPickerViewModel = EffectPickerViewModel(voiceSound: voiceSound)
        self.effectPickerViewModel?.didClickOnCreate = { [weak self] in
            self?.presentEffectCreator()
        }
        ///Action on effect pick
        self.effectPickerViewModel?.didPick = { [weak self] effect in
            self?.voiceSound?.effects = effect
            Player.shared.audioNodes.setEffects(effects: effect)
            
            ///Set up effect transition change configuration to avaudonodes
            if Player.shared.currentVoiceSound?.effects.effectTransitions.isEmpty == false && Player.shared.currentVoiceSound === self?.voiceSound && self?.voiceSound?.playerState.isPlaying == true{
                self?.voiceSound?.effects.currentValues.applyTransitionChanges = { effectPart in
                    Player.shared.audioNodes.applyTransitionChanges(effectTransitionPart: effectPart, effects: effect)
                }
            }
        }
    }
    
    init(voiceSound: VoiceSound?, listViewController: ListViewController?){
        self.voiceSound = voiceSound
        self.height = defaultHeight
        self.listViewController = listViewController
        if self.playerViewModel == nil && voiceSound != nil{
            setPlayerViewModel(voiceSound: voiceSound!)
        }
        if self.effectPickerViewModel == nil && voiceSound != nil{
            setEffectPickerViewModel(voiceSound: voiceSound!)
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
