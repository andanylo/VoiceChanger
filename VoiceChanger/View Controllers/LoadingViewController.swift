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
        view.backgroundColor = .white
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.view.addSubview(loadingView)
        
        loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        
    }

    
}
