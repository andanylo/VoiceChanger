//
//  LoadingViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 10.05.2021.
//

import Foundation
import UIKit

class LoadingViewController: UIViewController{
    
    var loadingViewModel: LoadingViewModel = LoadingViewModel()
    
    lazy var loadingView: LoadingView = {
        var view = LoadingView(frame: CGRect.zero)
        view.loadingViewModel = loadingViewModel
        view.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .init(white: 0.1, alpha: 1)
        return view
    }()
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setTheme()
    }
    func setTheme(){
        if #available(iOS 13.0, *) {
            
            if self.traitCollection.userInterfaceStyle == .dark{
                Variables.shared.currentDeviceTheme = .dark
            }
            else{
                Variables.shared.currentDeviceTheme = .normal
            }
            
        } else {
            Variables.shared.currentDeviceTheme = .normal
        }
        loadingView.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .init(white: 0.1, alpha: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.view.addSubview(loadingView)
        
        loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
    }

    
}
