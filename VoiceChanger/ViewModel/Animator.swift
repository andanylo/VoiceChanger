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
        
        if firstController is ListViewController, let popUpViewController = secondController as? PopUpController{
            let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(presenting ? 0 : 0.4)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            transitionContext.containerView.addSubview(backgroundView)
            
            backgroundView.leadingAnchor.constraint(equalTo: transitionContext.containerView.leadingAnchor).isActive = true
            backgroundView.topAnchor.constraint(equalTo: transitionContext.containerView.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: transitionContext.containerView.bottomAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: transitionContext.containerView.trailingAnchor).isActive = true
            
            guard let recordView = popUpViewController.mainView.snapshotView(afterScreenUpdates: true) else{
                transitionContext.completeTransition(true)
                return
            }
            
            transitionContext.containerView.addSubview(recordView)
            
            let starterRect = CGRect(x: popUpViewController.mainView.frame.origin.x, y: UIScreen.main.bounds.height, width: popUpViewController.mainView.frame.width, height: popUpViewController.mainView.frame.height)
            let finalRect = popUpViewController.mainView.frame
            
            recordView.frame = presenting ? starterRect : finalRect
            UIView.animate(withDuration: duration / 1.8) {
                backgroundView.backgroundColor = UIColor.black.withAlphaComponent(self.presenting ? 0.4 : 0)
            }
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: presenting ? 0.8 : 1, initialSpringVelocity: presenting ?  0.1 : 0, options: [.curveEaseOut], animations: {
                recordView.frame = self.presenting ? finalRect : starterRect
            }, completion: {_ in
                toView.isHidden = false
                [backgroundView, recordView].forEach({$0.removeFromSuperview()})
                transitionContext.completeTransition(true)
            })
           

        }
    }
    
    var presenting: Bool = false
    var firstViewController: UIViewController?
    var secondViewController: UIViewController?
    var duration: Double = 0.0
}

