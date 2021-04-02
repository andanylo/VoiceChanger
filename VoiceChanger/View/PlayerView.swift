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
    
    ///Play button
    private lazy var playButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(UIImage(named: "play"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.widthAnchor.constraint(equalToConstant: 35).isActive = true
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true
        button.addTarget(self, action: #selector(didClickOnPlayButton), for: .touchUpInside)
        return button
    }()
    
    ///Forward button
    private lazy var forwardButton: UIButton = {
        return createSkipButton(type: .forward)
    }()
    
    ///Back button
    private lazy var backButton: UIButton = {
        return createSkipButton(type: .back)
    }()
    
    ///Options
    private lazy var options: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Options", for: .normal)
        button.setTitleColor(UIColor(red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
        button.sizeToFit()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.height).isActive = true
        return UIButton()
    }()
    
    enum SkipButtonType{
        case forward
        case back
    }
    
    ///Creates the skip button
    func createSkipButton(type: SkipButtonType) -> UIButton{
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        button.setImage(UIImage(named: type == .forward ? "5secondskip" : "5skipback"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.widthAnchor.constraint(equalToConstant: 20).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.tag = type == .forward ? 1 : 2
        button.addTarget(self, action: #selector(didClickOnSkipButton(sender:)), for: .touchUpInside)
        return button
    }
    
    
    @objc func didClickOnPlayButton(){
        self.playerViewModel.didClickOnPlayButton()
    }
    
    @objc func didClickOnSkipButton(sender: UIButton){
        self.playerViewModel.didClickOnSkipButton(typeOfSkipButton: sender.tag == 1 ? .forward : .back)
    }
    
    private var previousValue: Float = 0.0

    
    ///did change value of player slider
    @objc func didChangeValue(sender: UISlider){
        if sender.value != previousValue{
            self.playerViewModel.didChangeTheValueOfSlider(value: sender.value)
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
            DispatchQueue.main.async{
                if isPlaying{
                    self?.playButton.setImage(UIImage(named: "stop"), for: .normal)
                }
                else{
                    self?.playButton.setImage(UIImage(named: "play"), for: .normal)
                }
            }
        }
        
        playerViewModel.onPlayerTimerChange = {  timer in
            let value = Float(timer.currTime)
            playerViewModel.updateSliderComponents(sliderValue: value)
        }
        
        playerViewModel.onSliderComponentChange = { [weak self] in
            let value: Float = Float(playerViewModel.sliderComponents.returnCombinedMiliseconds())
            DispatchQueue.main.async {
                self?.playerSlider.setValue(value, animated: false)
                self?.currentTimeLabel.updateText(from: self?.playerViewModel.sliderComponents)
                self?.remainingTimeLabel.updateText(from: self?.playerViewModel.remainingComponents)
            }
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(playerSlider)
        
        playerSlider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 35).isActive = true
        playerSlider.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -35).isActive = true
        playerSlider.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        
        self.addSubview(currentTimeLabel)
        
        currentTimeLabel.leadingAnchor.constraint(equalTo: playerSlider.leadingAnchor).isActive = true
        currentTimeLabel.topAnchor.constraint(equalTo: playerSlider.bottomAnchor, constant: -5).isActive = true
        
        self.addSubview(remainingTimeLabel)
        
        remainingTimeLabel.trailingAnchor.constraint(equalTo: playerSlider.trailingAnchor).isActive = true
        remainingTimeLabel.topAnchor.constraint(equalTo: playerSlider.bottomAnchor, constant: -5).isActive = true
        
        self.addSubview(playButton)

        playButton.topAnchor.constraint(equalTo: playerSlider.bottomAnchor, constant: 20).isActive = true
        playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.addSubview(forwardButton)
        
        forwardButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        forwardButton.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 20).isActive = true
        
        self.addSubview(backButton)
        
        backButton.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        backButton.trailingAnchor.constraint(equalTo: playButton.leadingAnchor, constant: -20).isActive = true
        
        self.addSubview(options)
        
        options.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        options.trailingAnchor.constraint(equalTo: playerSlider.trailingAnchor).isActive = true
    }
    
    init(playerViewModel: PlayerViewModel){
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
