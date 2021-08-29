//
//  VoiceSoundCell.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 17.03.2021.
//

import Foundation
import UIKit

class VoiceSoundCell: UICollectionViewCell{
    
    ///Name label
    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont(name: "Arial-BoldMT", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Label"
        label.textAlignment = .left
        label.sizeToFit()
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: label.frame.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.frame.height).isActive = true
        return label
    }()
    private var leadingNameLabelConstraint: NSLayoutConstraint?
    
    ///Disclosure indicator
    private lazy var disclosureIndicator: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "disclosure"))
        imageView.frame = CGRect(x: 0, y: 0, width: 10, height: 16)
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return imageView
    }()
    
    ///Remove button
    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .close)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: button.frame.size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.size.height).isActive = true
        button.addTarget(self, action: #selector(removeAction), for: .touchUpInside)
        return button
    }()
    
    ///Voice sound cell model, that updates the cell after setter
    var voiceSoundCellModel: VoiceSoundCellModel?{
        didSet{
            guard let voiceSound = voiceSoundCellModel?.voiceSound else{
                return
            }
   
            
            nameLabel.text = voiceSoundCellModel?.name
            audioFileDurationLabel.updateText(from: voiceSound.duration)
            playerView.playerViewModel = voiceSoundCellModel?.playerViewModel
            effectTemplatesView.effectPickerViewModel = voiceSoundCellModel?.effectPickerViewModel
            
           
            var rotationAngle: CGFloat = voiceSoundCellModel?.isSelected == true ? CGFloat.pi / 2 : 0
            disclosureIndicator.transform = CGAffineTransform(rotationAngle: rotationAngle)
            voiceSoundCellModel?.didSelect = { selected in
                rotationAngle = selected == true ? CGFloat.pi / 2 : 0
                if Player.shared.currentVoiceSound?.playerState.isPlaying == true{
                    Player.shared.stopPlaying(isPausing: false)
                }
                UIView.animate(withDuration: 0.2) {
                    self.disclosureIndicator.transform = CGAffineTransform(rotationAngle: rotationAngle)
                }
            }
        }
    }
    
    ///Method to change the nameLabel text
    func changeName(newName: String){
        nameLabel.text = newName
    }
    
    ///Label that displays the length of audio file
    private lazy var audioFileDurationLabel: TimerLabel = {
        let timerLabel = TimerLabel(timerLabelModel: TimerLabelModel(format: "mm:ss"))
        timerLabel.font = UIFont.systemFont(ofSize: 9)
        timerLabel.textColor = .darkGray
        return timerLabel
    }()
    
    ///Player view
    private lazy var playerView: PlayerView = {
        guard let playerViewModel = voiceSoundCellModel?.playerViewModel else{
            return PlayerView()
        }
        let view = PlayerView(playerViewModel: playerViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    ///Returns  the effect templates view
    private lazy var effectTemplatesView: EffectsPicker = {
        guard let effectPickerViewModel = voiceSoundCellModel?.effectPickerViewModel else{
            return EffectsPicker()
        }
        let effectsPicker = EffectsPicker(effectPickerViewModel: effectPickerViewModel)
        effectsPicker.translatesAutoresizingMaskIntoConstraints = false
        effectsPicker.heightAnchor.constraint(equalToConstant: 60).isActive = true
        effectsPicker.backgroundColor = .clear
        return effectsPicker
    }()
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
        
        leadingNameLabelConstraint?.isActive = false
        leadingNameLabelConstraint = nil
    }
    
    @objc func removeAction(){
        self.voiceSoundCellModel?.didRemoveButtonClicked(cell: self)
    }
    
    func start(with voiceSoundCellModel: VoiceSoundCellModel?, isEditing: Bool){

        self.voiceSoundCellModel = voiceSoundCellModel
        self.contentView.tag = 1
        
        self.backgroundColor = .clear
        
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = self.layer.cornerRadius
        if isEditing{
            self.contentView.addSubview(removeButton)
            
            removeButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
            removeButton.centerYAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (voiceSoundCellModel?.defaultHeight ?? 40) / 2).isActive = true
        }
        
        self.contentView.addSubview(nameLabel)
        
        leadingNameLabelConstraint = nameLabel.leadingAnchor.constraint(equalTo: isEditing ? removeButton.trailingAnchor : self.contentView.leadingAnchor, constant: 10)
        leadingNameLabelConstraint?.isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        
        self.contentView.addSubview(disclosureIndicator)
        
        disclosureIndicator.centerYAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (voiceSoundCellModel?.defaultHeight ?? 40) / 2).isActive = true
        disclosureIndicator.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        
        self.contentView.addSubview(audioFileDurationLabel)
        
        audioFileDurationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        audioFileDurationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        
        self.contentView.addSubview(effectTemplatesView)
        
        effectTemplatesView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        effectTemplatesView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        effectTemplatesView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (voiceSoundCellModel?.expandedHeight ?? 200) - (voiceSoundCellModel?.effectPickerViewModel?.height ?? 60)).isActive = true
        
        
        self.contentView.addSubview(playerView)
        
        playerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: voiceSoundCellModel?.defaultHeight ?? 50).isActive = true
        playerView.bottomAnchor.constraint(equalTo: effectTemplatesView.topAnchor).isActive = true
        playerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        
        setTheme()
    }
    
    
    ///Method that is called after the controller chaged state of editing
    func didChangeEditingState(isEditing: Bool){
        if isEditing{
            self.contentView.addSubview(removeButton)
            
            removeButton.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
            removeButton.centerYAnchor.constraint(equalTo: self.contentView.topAnchor, constant: (voiceSoundCellModel?.defaultHeight ?? 40) / 2).isActive = true
        }
        else{
            removeButton.removeFromSuperview()
        }
        
        leadingNameLabelConstraint?.isActive = false
        leadingNameLabelConstraint = nameLabel.leadingAnchor.constraint(equalTo: isEditing ? removeButton.trailingAnchor : self.contentView.leadingAnchor, constant: 10)
        leadingNameLabelConstraint?.isActive = true
    }
    
    
  
    func setTheme(){
        self.contentView.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .init(white: 0.1, alpha: 1)
        nameLabel.textColor = Variables.shared.currentDeviceTheme == .normal ? .black : .white
        audioFileDurationLabel.textColor = Variables.shared.currentDeviceTheme == .normal ? .darkGray : .lightGray
        playerView.setTheme()
        effectTemplatesView.setTheme()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let location = touch.location(in: self)
        if self.hitTest(location, with: event)?.tag == 1{
            voiceSoundCellModel?.changeSelected()
        }
    }
    
}

