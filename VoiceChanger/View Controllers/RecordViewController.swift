//
//  RecordViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import Foundation
import UIKit

class RecordViewController: UIViewController{
    var recorder = Recorder()
    
    var timer = Timer()
    
    var button: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        button.setTitle("Button", for: .normal)
        button.setTitleColor(.init(red: 0/255, green: 122/255, blue: 1, alpha: 1), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.height).isActive = true
        button.addTarget(self, action: #selector(start), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recorder.delegate = self
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(button)
    
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
    }
    
    @objc func start(){
        recorder.validateAndStart(name: "test")
    }
    @objc func db(){
        print(recorder.audioRecorder.averagePower(forChannel: 0))
    }
}

extension RecordViewController: RecorderDelegate{
    func didStartRecording() {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(db), userInfo: nil, repeats: true)
    }
    
    func didStopRecording() {
        
    }
    
    
}
