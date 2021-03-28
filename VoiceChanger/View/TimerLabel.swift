//
//  TimerLabel.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation
import UIKit

// Class that represents the timer label
class TimerLabel: UILabel{
    var timerLabelModel: TimerLabelModel!
    
    init(timerLabelModel: TimerLabelModel){
        super.init(frame: CGRect.zero)
        self.timerLabelModel = timerLabelModel
        self.updateText(from: nil)
        
        self.sizeToFit()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: self.frame.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
    }
    
    ///Method that updates the text from timer
    func updateText(from timeComponents: TimeComponents?){
        self.text = self.timerLabelModel.returnText(from: timeComponents ?? TimeComponents())
    }
    
    ///Resets the timer label
    func reset(){
        self.updateText(from: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
