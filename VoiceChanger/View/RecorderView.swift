//
//  RecorderView.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.03.2021.
//

import Foundation
import UIKit

///Class that represents the recorder view
class RecorderView: UIView{
    
    private var voiceSound: VoiceSound!
    
    ///Returns name field for the record
    lazy var nameField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont(name: "Arial-BoldMT", size: 32)
        textField.tintColor = .clear
        textField.borderStyle = .none
        textField.textAlignment = .center
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.text = voiceSound.name
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return textField
    }()
    
    ///Returns the audioWave
    lazy var audioWave: RecorderAudioWave = {
        let view = RecorderAudioWave(spacing: 1, tileWidth: nil, audioWaveModel: AudioWaveModel(numberOfTiles: 50, refreshInterval: 0.05))
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 58).isActive = true
        return view
    }()
    
    ///Returns the label that represents currend time in seconds
    lazy var timerLabel: TimerLabel = {
        let label = TimerLabel(timerLabelModel: TimerLabelModel(format: "mm:ss.MM"))
        label.textColor = .black
        label.font = UIFont(name: "Arial", size: 17)
        return label
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 73, height: 73)
        button.addTarget(self, action: #selector(didClickRecordButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.height).isActive = true
        return button
    }()
    
    func changeStateOfRecordButton(isPlaying: Bool){
        if isPlaying{
            recordButton.layer.cornerRadius = 20
            recordButton.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        }
        else{
            recordButton.layer.cornerRadius = recordButton.frame.width / 2
            recordButton.backgroundColor = UIColor(red: 221 / 255, green: 0, blue: 0, alpha: 1)
        }
    }
    
    weak var delegate: RecorderViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    init(){
        super.init(frame: CGRect.zero)
    }
    init(voiceSound: VoiceSound){
        super.init(frame: CGRect.zero)
        
        self.voiceSound = voiceSound
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.addSubview(nameField)

        nameField.topAnchor.constraint(equalTo: self.topAnchor, constant: 55).isActive = true
        nameField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        nameField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true

        self.addSubview(audioWave)

        audioWave.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 30).isActive = true
        audioWave.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        audioWave.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true

        self.layoutIfNeeded()
        self.addSubview(timerLabel)

        timerLabel.topAnchor.constraint(equalTo: audioWave.bottomAnchor, constant: 20).isActive = true
        timerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        self.addSubview(recordButton)

        recordButton.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 20).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true

        changeStateOfRecordButton(isPlaying: false)
    }
    
    func setTheme(){
        nameField.textColor = Variables.shared.currentDeviceTheme == .normal ? .black : .white
        timerLabel.textColor = Variables.shared.currentDeviceTheme == .normal ? .black : .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func didClickRecordButton(){
        delegate?.didClickRecordButton()
    }
}

///Extensions that inherit from other protocols
extension RecorderView: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        voiceSound.name = textField.text ?? ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.superview?.endEditing(true)
        return false
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.tintColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        return true
    }
}

protocol RecorderViewDelegate: AnyObject{
    func didClickRecordButton()
}

