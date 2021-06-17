//
//  LoadingView.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 10.05.2021.
//

import Foundation
import UIKit

class LoadingView: UIView{
    
    var loadingViewModel: LoadingViewModel!{
        didSet{
            if oldValue != nil{
                oldValue.stateChangeHandler = nil
            }
            loadingViewModel.stateChangeHandler = { state in
                self.didChangeState(state: state)
            }
        }
    }
    
    lazy var activityView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        activity.style = .medium
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.widthAnchor.constraint(equalToConstant: 20).isActive = true
        activity.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return activity
    }()
    lazy var resultImageView: UIImageView = {
        guard let image = UIImage(named: loadingViewModel.currentImageName ?? "dots")?.withRenderingMode(.alwaysTemplate) else{
            return UIImageView()
        }
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.widthAnchor.constraint(equalToConstant: 70).isActive = true
        self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.layer.cornerRadius = 15
        
        
    }
    
    func didChangeState(state: LoadingViewModel.LoadingState){
        switch state{
        
        case .loading:
            
            self.addSubview(activityView)
            
            self.activityView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.activityView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            
            activityView.startAnimating()
        
        case .error, .loadedSuccessfully:
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            
            self.addSubview(resultImageView)
            
            self.resultImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            self.resultImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            self.resultImageView.tintColor = state == .error ? .red : UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if loadingViewModel != nil{
            loadingViewModel.state = .loading
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}
