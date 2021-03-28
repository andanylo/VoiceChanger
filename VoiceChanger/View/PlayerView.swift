//
//  PlayerView.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 26.03.2021.
//

import Foundation
import UIKit
class PlayerView: UIView{
    var playerViewModel: PlayerViewModel!{
        didSet{
            setUp(playerViewModel: self.playerViewModel)
        }
    }
    
    ///Player slider
    private lazy var playerSlider: UISlider = {
        let slider = UISlider()
        slider.sizeToFit()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor.darkGray
        slider.heightAnchor.constraint(equalToConstant: slider.frame.height).isActive = true
        
        let thumbView: UIView = UIView()
        thumbView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        thumbView.backgroundColor = UIColor.darkGray
        thumbView.layer.cornerRadius = thumbView.frame.width / 2
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        let image = renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
        slider.setThumbImage(image, for: .normal)
        
        slider.addTarget(self, action: #selector(didChangeValue(sender:)), for: .valueChanged)
        return slider
    }()
    
    ///Label that displays current time
    private lazy var currentTimeLabel: TimerLabel = {
        let label = TimerLabel(timerLabelModel: TimerLabelModel(format: "mm:ss"))
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = .darkGray
        return label
    }()
    
    ///Label that displays the remaining time
    private lazy var remainingTimeLabel: TimerLabel = {
        let label = TimerLabel(timerLabelModel: TimerLabelModel(format: "-mm:ss"))
        label.font = UIFont.systemFont(ofSize: 9)
        label.textColor = .darkGray
        label.textAlignment = .right

        return label
    }()
    
    private lazy var playButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private var previousValue: Float = 0.0
    
    ///Updates the view components on change of timeComponents
    func updateOnChange(){
        self.currentTimeLabel.updateText(from: self.playerViewModel.sliderComponents)
        self.remainingTimeLabel.updateText(from: self.playerViewModel.remainingComponents)
    }
    
    ///did change value of player slider
    @objc func didChangeValue(sender: UISlider){
        if sender.value != previousValue{
            self.playerViewModel.updateSliderComponents(sliderValue: sender.value)
            updateOnChange()
            self.previousValue = sender.value
        }
    }
    
    ///Setups the player view
    private func setUp(playerViewModel: PlayerViewModel){
        guard let duration = playerViewModel.voiceSound?.duration else{
            return
        }
        playerSlider.minimumValue = 0
        playerSlider.maximumValue = playerViewModel.returnSliderValue(current: duration)
        
        playerSlider.value = 0.0
        remainingTimeLabel.updateText(from: playerViewModel.remainingComponents)
        
        playerViewModel.onPlayStateChange = { [weak self] isPlaying in
            if isPlaying{
                
            }
            else{
                
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(playerSlider)
        
        playerSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 50).isActive = true
        playerSlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50).isActive = true
        playerSlider.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        self.addSubview(currentTimeLabel)
        
        currentTimeLabel.leadingAnchor.constraint(equalTo: playerSlider.leadingAnchor).isActive = true
        currentTimeLabel.topAnchor.constraint(equalTo: playerSlider.bottomAnchor, constant: -5).isActive = true
        
        self.addSubview(remainingTimeLabel)
        
        remainingTimeLabel.trailingAnchor.constraint(equalTo: playerSlider.trailingAnchor).isActive = true
        remainingTimeLabel.topAnchor.constraint(equalTo: playerSlider.bottomAnchor, constant: -5).isActive = true
    }
    
    init(playerViewModel: PlayerViewModel){
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
