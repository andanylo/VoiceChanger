//
//  RecordViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import Foundation
import UIKit

class RecordViewController: UIViewController, KeyboardDelegate{
    var extendedByKeyboard: Bool = false
    
    ///Action, or animation when keyboard changes it's state
    func willChangeState(keyboardHeight: CGFloat, keyboardAnimationDuration: Double, state: KeyboardManager.State) {
        let nameFieldMaxY = self.recorderBackground.convert(CGPoint(x: 0, y: self.recorderBackground.nameField.frame.maxY), to: self.view).y
        let keyboardMinY = UIScreen.main.bounds.height - keyboardHeight
        if nameFieldMaxY > keyboardMinY || (extendedByKeyboard && state == .hidden){
            extendedByKeyboard = extendedByKeyboard ? false : true
            
            let difference = nameFieldMaxY - keyboardMinY + 20
            recorderBackgroundTopConstraint.constant = state == KeyboardManager.State.showed ? topRecordBackgroundConstant - difference : topRecordBackgroundConstant
            UIView.animate(withDuration: keyboardAnimationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    var recorder = Recorder()
    var voiceSound: VoiceSound!
    var delegate: RecordViewControllerDelegate?
    
    ///Returns the recorder  view with audio wave and record button
    lazy var recorderBackground: RecorderView = {
        let view = RecorderView(voiceSound: self.voiceSound)
        view.frame.size = UIScreen.main.bounds.size
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 45
        view.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true
        return view
    }()
    private let topRecordBackgroundConstant: CGFloat = 50
    private var recorderBackgroundTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tag = 1
        voiceSound = VoiceSound(lastPathComponent: "testing.m4a")
        voiceSound.name = "Example"
        recorder.delegate = self
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        self.view.addSubview(recorderBackground)
        recorderBackground.delegate = self
        
        recorderBackground.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recorderBackgroundTopConstraint = recorderBackground.topAnchor.constraint(equalTo: self.view.centerYAnchor, constant: topRecordBackgroundConstant)
        recorderBackgroundTopConstraint.isActive = true
        
        KeyboardManager.shared.delegate = self
        
        recorder.recordTimer.delegate = self
    }
    
    ///View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        if voiceSound.fileExists{
            delegate?.willSave(voiceSound: self.voiceSound)
        }
        if recorder.isRecording{
            let fileExists = voiceSound.fileExists
            recorder.stopRecording()
            if !fileExists {
                try? voiceSound.removeSound()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let view = self.view.hitTest(touch.location(in: self.view), with: nil)
        if view?.tag == 1{
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension RecordViewController: RecorderDelegate{
    func didStartRecording() {
        
    }
    
    func didStopRecording() {
        DispatchQueue.main.async{
            self.recorderBackground.audioWave.reset()
            self.recorderBackground.timerLabel.reset()
        }
    }
}

///Delegate of recorder
extension RecordViewController: RecorderViewDelegate{
    func didClickRecordButton() {
        if !recorder.isRecording{
            recorder.validateAndStart(voiceSound: voiceSound, errorHandler: { error in
                print("error occured")
            })
        }
        else{
            recorder.stopRecording()
        }
    }
}

///Delegate of a custom timer
extension RecordViewController: CustomTimerDelegate{
    func timerBlock(timer: CustomTimer) {
        DispatchQueue.main.async {
            self.recorderBackground.timerLabel.updateText(from: timer)
            self.recorderBackground.audioWave.update(timer: timer, recorder: self.recorder)
        }
    }
}

protocol RecordViewControllerDelegate{
    func willSave(voiceSound: VoiceSound)
}
