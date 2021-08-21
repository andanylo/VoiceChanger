//
//  EffectCreatorController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.05.2021.
//

import Foundation
import UIKit

class EffectCreatorController: UIViewController, PopUpChildProtocol{
    
    override func loadView() {
        self.view = UIView()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        setTheme()
    }
    func setTheme() {
       // self.view.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .init(white: 0.1, alpha: 1)
    }
}
