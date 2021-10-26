//
//  EffectTemplateViewModel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.04.2021.
//

import Foundation
import UIKit
///Class that represent the effect template view model
class EffectTemplateViewModel{
    enum ViewModelType{
        case empty
        case template
    }
    
    ///Effect associated with template
    var effects: Effects?
    
    var type: ViewModelType
    ///Image name for template
    var imageName: String?
    var size: CGSize{
        get{
            return type == .empty ? CGSize(width: 20, height: 20) : CGSize(width: 40, height: 40)
        }
    }
    
    ///Is currently selected
    var isSelected: Bool = false{
        didSet{
            didSelect?(isSelected)
        }
    }
    
    ///On selection state change
    var didSelect: ((Bool) -> Void)?
    
    init(type: ViewModelType, effects: Effects?, imageName: String){
        self.type = type
        self.effects = effects
        self.imageName = imageName
    }
}
