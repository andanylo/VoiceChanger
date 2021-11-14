//
//  RecordViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import Foundation
import UIKit

class RecordViewController: UIViewController, PopUpChildProtocol{
    
    var recorder = Recorder()
    lazy var voiceSound: VoiceSound = {
        let voiceSound = VoiceSound()
        voiceSound.name = "Example"
        return voiceSound
    }()
    weak var delegate: RecordViewControllerDelegate?
    
    var recorderView: RecorderView?{
        get{
            return self.view as? RecorderView
        }
    }
    
    var isRerecording: Bool = false
    var startedRecording: Bool = false
    
    ///Returns the recorder  view with audio wave and record button
    override func loadView() {
        self.view = RecorderView(voiceSound: self.voiceSound)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startedRecording = false
        
        recorder.delegate = self
        
        (self.view as? RecorderView)?.delegate = self
        self.view.layoutIfNeeded()
        
        recorder.recordTimer.delegate = self
        setTheme()
    }
    
    func setTheme(){
        recorderView?.setTheme()
    }
    
    ///View will disappear
    override func viewWillDisappear(_ animated: Bool) {
        
        if startedRecording && !isRerecording{
            if voiceSound.fileExists && !recorder.isRecording{
                delegate?.willSave(voiceSound: self.voiceSound)
            }
            if recorder.isRecording{
                let fileExists = voiceSound.fileExists
                recorder.stopRecording()
                if fileExists {
                    try? voiceSound.removeSound()
                }
            }
        }
        else{
            isRerecording = false
        }
        
        
    }
    
    
}

extension RecordViewController: RecorderDelegate{
    func didStartRecording() {
        self.startedRecording = true
        DispatchQueue.main.async {
            (self.view as? RecorderView)?.changeStateOfRecordButton(isPlaying: true)
        }
    }
    
    func didStopRecording() {
        DispatchQueue.main.async{
            (self.view as? RecorderView)?.changeStateOfRecordButton(isPlaying: false)
            self.parent?.dismiss(animated: true, completion: {[weak self] in self?.delegate?.didSave()})
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
            (self.view as? RecorderView)?.timerLabel.updateText(from: timer.timeComponents)
            (self.view as? RecorderView)?.audioWave.update(timer: timer, recorder: self.recorder)
        }
    }
}

protocol RecordViewControllerDelegate: AnyObject{
    func willSave(voiceSound: VoiceSound)
    func didSave()
}
