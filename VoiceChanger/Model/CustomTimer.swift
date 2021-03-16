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
            ///Set miliseconds
            timeComponents.miliseconds = currTime - Int(Double(currTime / 1000)) * 1000
            
            ///Set minutes
            timeComponents.minutes = currTime / 1000 / 60
            
            ///Set seconds
            timeComponents.seconds = currTime / 1000 - timeComponents.minutes * 60
        }
    }
    
    var timeComponents: TimeComponents = TimeComponents()
    
    
    var delegate: CustomTimerDelegate?
    
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
            self.isRunning = true
        }
        
    }
    
    ///Pauses the timer
    func pause(){
        timer?.invalidate()
        isRunning = false
    }
    
    ///Resets the timer
    func reset(){
        if isRunning{
            pause()
        }
        currTime = 0
    }
    
    
    func setCurrentTime(from components: TimeComponents){
        currTime = components.miliseconds + components.seconds * 1000 + components.minutes * 60 * 1000
    }
}

protocol CustomTimerDelegate{
    func timerBlock(timer: CustomTimer)
}
