//
//  PopUpController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.05.2021.
//

import Foundation
import UIKit

class PopUpController: UIViewController, KeyboardDelegate{
    var extendedByKeyboard: Bool = false
    
    ///Action, or animation when keyboard changes it's state
    func willChangeState(keyboardHeight: CGFloat, keyboardAnimationDuration: Double, state: KeyboardManager.State) {
        if let recorderViewController = containerViewController as? RecordViewController, let recorderView = recorderViewController.view as? RecorderView{
            let nameFieldMaxY = recorderView.convert(CGPoint(x: 0, y: recorderView.nameField.frame.maxY), to: self.view).y
            let keyboardMinY = UIScreen.main.bounds.height - keyboardHeight
            if nameFieldMaxY > keyboardMinY || (extendedByKeyboard && state == .hidden){
                extendedByKeyboard = extendedByKeyboard ? false : true
                
                let difference = nameFieldMaxY - keyboardMinY + 20
                mainTopConstraint.constant = state == KeyboardManager.State.showed ? topMainConstant - difference : topMainConstant
                UIView.animate(withDuration: keyboardAnimationDuration) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    enum PopUpCategory{
        case record
        case effect
    }
    
    var popUpCategory: PopUpCategory!
    
    var dismissesOnTouch = true
    
    var prefferedHeight: CGFloat{
        get{
            return popUpCategory == .record ? 336.5 : 400
        }
    }
    
    
    
    lazy var mainView: UIView = {
        let view = UIView()
        view.frame.size = UIScreen.main.bounds.size
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 45
        view.clipsToBounds = true
        view.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.frame.size.height = prefferedHeight
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        return view
    }()
    var containerViewController: UIViewController?
    var rootViewController: UIViewController?
    
    var objectToTransfer: AnyObject?
    
    private var topMainConstant: CGFloat = 50
    private var mainTopConstraint: NSLayoutConstraint!
    
    
    init(rootViewController: UIViewController?){
        super.init(nibName: nil, bundle: nil)
        self.rootViewController = rootViewController
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tag = 1
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.view.addSubview(mainView)
        self.view.layoutIfNeeded()
        
        KeyboardManager.shared.delegate = self
        
        topMainConstant = -prefferedHeight
        
        mainView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        mainTopConstraint = mainView.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: topMainConstant)
        mainTopConstraint.isActive = true
        
        mainView.addSubview(containerView)
        
        containerView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: mainView.topAnchor).isActive = true
        
        if popUpCategory == .record{
            containerViewController = RecordViewController()
            guard let recordViewController = containerViewController as? RecordViewController else{
                return
            }
            recordViewController.delegate = rootViewController as? RecordViewControllerDelegate
            
            if let voiceSound = objectToTransfer as? VoiceSound{
                recordViewController.voiceSound = voiceSound
            }
        }
        else if popUpCategory == .effect{
            containerViewController = EffectCreatorController()
        }
        guard let containerViewController = containerViewController else{
            return
        }
        containerView.addSubview(containerViewController.view)
        
        containerViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        containerViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        containerViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        containerViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        self.addChild(containerViewController)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let view = self.view.hitTest(touch.location(in: self.view), with: nil)
        if view?.tag == 1{
            if KeyboardManager.shared.state == KeyboardManager.State.showed{
                self.view.endEditing(true)
            }
            else{
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
}
