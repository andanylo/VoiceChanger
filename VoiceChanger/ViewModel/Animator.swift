//
//  Animator.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation
import UIKit

///Class that handles custom view controller animations
class Animator: NSObject, UIViewControllerAnimatedTransitioning{
    static var shared = Animator()
    
    ///Returns the duration of animation
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    ///Perform custom animation on the container view of transition context
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let firstController = firstViewController, let secondController = secondViewController, let toView = transitionContext.view(forKey: presenting ? .to : .from) else{
            transitionContext.completeTransition(true)
            return
        }
        
      
        toView.isHidden = true
        toView.layoutIfNeeded()
        transitionContext.containerView.addSubview(toView)
        transitionContext.containerView.sendSubviewToBack(toView)
        
        let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(presenting ? 0 : 0.4)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        transitionContext.containerView.addSubview(backgroundView)
        
        backgroundView.leadingAnchor.constraint(equalTo: transitionContext.containerView.leadingAnchor).isActive = true
        backgroundView.topAnchor.constraint(equalTo: transitionContext.containerView.topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: transitionContext.containerView.bottomAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: transitionContext.containerView.trailingAnchor).isActive = true
        
        var animation: (() -> Void)?
        var completion: (() -> Void)?
        var withSpring = false
        
        if firstController is ListViewController, let popUpViewController = secondController as? PopUpController{

            let recordView = UIView()
            recordView.layer.cornerRadius = popUpViewController.mainView.layer.cornerRadius
            recordView.backgroundColor = popUpViewController.mainView.backgroundColor
            
            let renderer = UIGraphicsImageRenderer(bounds: popUpViewController.mainView.bounds)
            let image = renderer.image { rendererContext in
                popUpViewController.mainView.layer.render(in: rendererContext.cgContext)
            }
            let imageView = UIImageView(image: image)
            recordView.addSubview(imageView)
            
            let starterRect = CGRect(x: popUpViewController.mainView.frame.origin.x, y: UIScreen.main.bounds.height, width: popUpViewController.mainView.frame.width, height: popUpViewController.mainView.frame.height)
            let finalRect = popUpViewController.mainView.frame
            
            recordView.frame = presenting ? starterRect : finalRect
            
            transitionContext.containerView.addSubview(recordView)
            UIView.animate(withDuration: duration / 1.8) {
                backgroundView.backgroundColor = UIColor.black.withAlphaComponent(self.presenting ? 0.4 : 0)
            }
            animation = { [weak self] in
                recordView.frame = self?.presenting == true ? finalRect : starterRect
            }
            completion = {
                [backgroundView, recordView].forEach({$0.removeFromSuperview()})
                transitionContext.completeTransition(true)
                toView.isHidden = false
            }
            withSpring = true
        }
        else if firstController is ListViewController, let loadingViewController = secondController as? LoadingViewController{
            
            let loadView = LoadingView(frame: loadingViewController.loadingView.frame)
            loadView.translatesAutoresizingMaskIntoConstraints = true
            loadView.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .init(white: 0.1, alpha: 1)
            transitionContext.containerView.addSubview(loadView)
            
            loadView.loadingViewModel = LoadingViewModel()
            loadView.loadingViewModel.state = loadingViewController.loadingViewModel.state
            
            
            loadView.frame = loadingViewController.loadingView.frame
            
            let scale: CGFloat = presenting ? 1.1 : 1
            loadView.transform = CGAffineTransform(scaleX: scale, y: scale)
            loadView.alpha = presenting ? 0 : 1
            
            let newScale: CGFloat = presenting ? 1 : 1.1
            animation = { [weak self] in
                backgroundView.backgroundColor = UIColor.black.withAlphaComponent(self?.presenting == true ? 0.4 : 0)
                loadView.transform = CGAffineTransform(scaleX: newScale, y: newScale)
                loadView.alpha = self?.presenting == true ? 1 : 0
            }
            completion = {
                toView.isHidden = false
                [backgroundView, loadView].forEach({$0.removeFromSuperview()})
                transitionContext.completeTransition(true)
            }
            withSpring = false
        }
        
        if withSpring{
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: presenting ? 0.8 : 1, initialSpringVelocity: presenting ?  0.1 : 0, options: [.curveEaseOut]) {
                animation?()
            } completion: { _ in
                completion?()
            }

        }
        else{
            UIView.animate(withDuration: duration, animations: {
                animation?()
            }) { _ in
                completion?()
            }
        }
    }
    
    var presenting: Bool = false
    var firstViewController: UIViewController?
    var secondViewController: UIViewController?
    var duration: Double = 0.0
}

