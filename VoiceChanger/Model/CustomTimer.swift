//
//  RecordTimer.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation

///Class that creates timer, counts the time, and has time modules parameters
class CustomTimer{
    ///Object's timer
    private var timer: Timer?
    
    ///Timer is running
    var isRunning = false
    
    ///Update current components
    var currTime: Int = 0{
        didSet{
            self.timeComponents.convertFromMiliseconds(miliseconds: currTime)
        }
    }
    
    var timeComponents: TimeComponents = TimeComponents()
    
    weak var delegate: CustomTimerDelegate?
    
    var timeInterval = 0.0
    init(timeInterval: TimeInterval){
        self.timeInterval = timeInterval
    }
    
    
    ///Starts the timer
    func start(){
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true, block: { (timer) in
                self.currTime += 1
                self.delegate?.timerBlock(timer: self)
            })
            RunLoop.current.add(self.timer!, forMode: .common)
            self.isRunning = true
            
        }
        
    }
    
    ///Pauses the timer
    func pause(){
        if timer != nil{
            self.timer?.invalidate()
        }
        self.isRunning = false
    }
    
    ///Resets the timer
    func reset(){
        pause()
        currTime = 0
        self.delegate?.timerBlock(timer: self)
    }
    
    
    func setCurrentTime(from components: TimeComponents){
        currTime = components.returnCombinedMiliseconds()
    }
}

protocol CustomTimerDelegate: AnyObject{
    func timerBlock(timer: CustomTimer)
}
