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
            
            if voiceSoundCellModel?.playerViewModel != nil{
                playerView.playerViewModel = voiceSoundCellModel?.playerViewModel
            }

            var rotationAngle: CGFloat = voiceSoundCellModel?.isSelected == true ? CGFloat.pi / 2 : 0
            oldValue?.didSelect = nil
            disclosureIndicator.transform = CGAffineTransform(rotationAngle: rotationAngle)
            voiceSoundCellModel?.didSelect = { selected in
                rotationAngle = selected == true ? CGFloat.pi / 2 : 0
                
                Player.shared.stopPlaying(isPausing: false)
                
                UIView.animate(withDuration: 0.2) {
                    self.disclosureIndicator.transform = CGAffineTransform(rotationAngle: rotationAngle)
                }
            }
        }
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
        let view = PlayerView(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.subviews.forEach({$0.removeFromSuperview()})
        
        leadingNameLabelConstraint?.isActive = false
        leadingNameLabelConstraint = nil
        
        self.voiceSoundCellModel?.playerViewModel?.onPlayStateChange = nil
        self.voiceSoundCellModel?.playerViewModel?.onPlayerCurrentTimeChange = nil
        self.voiceSoundCellModel?.playerViewModel?.onSliderComponentChange = nil
        self.voiceSoundCellModel?.playerViewModel?.onClickOptionsButton = nil
    }
    
    @objc func removeAction(){
        self.voiceSoundCellModel?.didRemoveButtonClicked(cell: self)
    }
    
    func start(with voiceSoundCellModel: VoiceSoundCellModel?, isEditing: Bool){
        self.contentView.tag = 1
        
        
        self.backgroundColor = .white
        
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
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
        
        audioFileDurationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0).isActive = true
        audioFileDurationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        
        self.contentView.addSubview(playerView)
        
        playerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: voiceSoundCellModel?.defaultHeight ?? 50).isActive = true
        playerView.heightAnchor.constraint(equalToConstant: (voiceSoundCellModel?.expandedHeight ?? 200) - (voiceSoundCellModel?.defaultHeight ?? 50)).isActive = true
        playerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        playerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        
        self.voiceSoundCellModel = voiceSoundCellModel
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{
            return
        }
        let location = touch.location(in: self)
        if self.hitTest(location, with: event)?.tag == 1{
            voiceSoundCellModel?.changeSelected()
        }
    }
}
