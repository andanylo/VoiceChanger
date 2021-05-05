//
//  EffectCreatorController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.05.2021.
//

import Foundation
import UIKit

class EffectCreatorController: UIViewController{
    
    override func loadView() {
        self.view = UIView()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
    }
}
