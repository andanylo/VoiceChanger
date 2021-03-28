//
//  VoiceSoundCellModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 17.03.2021.
//

import Foundation
import UIKit

class VoiceSoundCellModel{
    var voiceSound: VoiceSound?
    
    ///Returns the name of the cell
    var name: String?{
        get{
            return voiceSound?.name
        }
    }
    
    weak var listViewController: ListViewController?
    
    ///Height of the cell
    var defaultHeight: CGFloat = 50
    private var _height: CGFloat = 0.0
    var height: CGFloat{
        set(value){
            self._height = value
        }
        get{
            return isSelected == true ? self._height * 3 : self._height
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
    
    
    
    init(voiceSound: VoiceSound?, listViewController: ListViewController?){
        self.voiceSound = voiceSound
        self.height = defaultHeight
        self.listViewController = listViewController
    }
    
    ///Remove the cell
    func didRemoveButtonClicked(cell: VoiceSoundCell?){
        guard let cell = cell else{
            return
        }
        self.listViewController?.collectionViewDeleteAction(cell: cell)
    }
}
