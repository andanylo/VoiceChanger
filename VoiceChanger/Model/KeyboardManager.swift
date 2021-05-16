//
//  KeyboardManager.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation
import UIKit

///Class that handles keyboard
class KeyboardManager{
    
    static var shared = KeyboardManager()
    
    weak var delegate: KeyboardDelegate?
    
    var keyboardHeight: CGFloat = 0.0
    var keyboardAnimationDuration: Double = 0.0
    var state: State?
    
    init(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    ///Function that indicates that keyboard has been shown
    @objc private func keyboardWillShow(_ notification: NSNotification){
        self.state = .showed
        handleNotification(notification)
    }
    
    ///Function that indicates that keyboard has been hidden
    @objc private func keyboardWillHide(_ notification: NSNotification){
        self.state = .hidden
        handleNotification(notification)
    }
    
    private func handleNotification(_ notification: NSNotification){
        self.keyboardHeight = ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero).height
        self.keyboardAnimationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.4
        delegate?.willChangeState(keyboardHeight: self.keyboardHeight, keyboardAnimationDuration: self.keyboardAnimationDuration, state: self.state ?? .none)
    }
    
    enum State{
        case showed
        case hidden
        case none
    }
}
protocol KeyboardDelegate: AnyObject{
    var extendedByKeyboard: Bool{
        get set
    }
    func willChangeState(keyboardHeight: CGFloat, keyboardAnimationDuration: Double, state: KeyboardManager.State)
}
