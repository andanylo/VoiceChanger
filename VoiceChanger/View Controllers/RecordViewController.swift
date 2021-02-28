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
    
    lazy var button: UIButton = {
        let recordButton = UIButton(type: .system)
        recordButton.setTitle("Button", for: .normal)
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchUpInside)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.sizeToFit()
        recordButton.widthAnchor.constraint(equalToConstant: recordButton.frame.width).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: recordButton.frame.height).isActive = true
        return recordButton
    }()
    
    @objc func startRecording(){
        if !recorder.isRecording{
            recorder.validateAndStart(name: "testing")
        }
        else{
            let newSound = recorder.stopRecording()
            
            do{
                try Player.shared.playFile(filePath: newSound.path, effects: Effects(speed: 1, pitch: 0, distortion: 0, reverb: 100))
            }
            catch{
                print("can't")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recorder.delegate = self
        
        self.view.backgroundColor = .white
        self.view.addSubview(button)
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    
}

extension RecordViewController: RecorderDelegate{
    func didStartRecording() {
        //timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(db), userInfo: nil, repeats: true)
    }
    
    func didStopRecording() {
        //timer.invalidate()

    }
    
    
}
