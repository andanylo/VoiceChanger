//
//  EffectsCollectionView.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.04.2021.
//

import Foundation
import UIKit

///Class that represent the effect templates picker
class EffectsPicker: UIView{
    private let effects = [
        ///Normal
        Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0),
        ///Drunk
        Effects(speed: 0.6, pitch: -100, distortion: 0, reverb: 0),
        ///Robot
        Effects(speed: 1, pitch: -400, distortion: 10, reverb: 0),
        ///small robot
        Effects(speed: 1, pitch: 400, distortion: 10, reverb: 0, distortionPreset: .multiEchoTight1, reverbPreset: nil),
        //Bee
        Effects(speed: 1.5, pitch: 1000, distortion: 5, reverb: 0, distortionPreset: .speechWaves, reverbPreset: nil),
        ///alien
        Effects(speed: 1, pitch: 200, distortion: 10, reverb: 0, distortionPreset: .speechCosmicInterference, reverbPreset: nil),
        ///Canyon
        Effects(speed: 1, pitch: 0, distortion: 100, reverb: 5, distortionPreset: .multiEcho2, reverbPreset: .cathedral),
        ///Scary/devil
        Effects(speed: 0.8, pitch: -1000, distortion: 0, reverb: 0),
        ///Fast and helium
        Effects(speed: 2, pitch: 2000, distortion: 0, reverb: 0),
        ///Slow
        Effects(speed: 0.5, pitch: -2000, distortion: 0, reverb: 0)
    ]
    
    var effectsTemplateViewModels = [EffectTemplateViewModel]()
    
    var selectedEffectsTemplate: EffectTemplateViewModel?{
        didSet{
            selectedEffectsTemplate?.isSelected = true
            guard let effects = selectedEffectsTemplate?.effects else{
                return
            }
            delegate?.didPick(effects: effects)
        }
    }
    
    weak var delegate: EffectsPickerDelegate?{
        didSet{
            guard let effects = selectedEffectsTemplate?.effects else{
                return
            }
            delegate?.didPick(effects: effects)
        }
    }
    
    ///Collection view to display templates
    lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: collectionViewLayout)
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(EffectTemplateCell.self, forCellWithReuseIdentifier: "EffectTemplateCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    init(){
        super.init(frame: CGRect.zero)
        
        self.effectsTemplateViewModels = effects.map({return EffectTemplateViewModel(type: .template, effects: $0)})
        self.effectsTemplateViewModels.insert(EffectTemplateViewModel(type: .empty, effects: nil), at: 0)
        
        //low battery
        let transitionEffect = Effects(speed: 1, pitch: 0, distortion: 0, reverb: 0)
        transitionEffect.effectTransitions = [EffectTransition(effects: transitionEffect, startPoint: .custom(1/2), endPoint: .custom(1), fromValue: transitionEffect.standardValues.speed, transitionValue: 0.2, effectPartToTransition: .speed),
                                              EffectTransition(effects: transitionEffect, startPoint: .custom(1/2), endPoint: .custom(1), fromValue: 0, transitionValue: -500, effectPartToTransition: .pitch)
        ]
        
        //Test
        let transitionEffect2 = Effects(speed: 1, pitch: 1000, distortion: 0, reverb: 0)
        
        for i in 0..<50{
            transitionEffect2.effectTransitions.append(EffectTransition(effects: transitionEffect2, startPoint: .custom(Double(i) / 50.0), endPoint: .custom(Double(i+1) / 50.0), fromValue: (i % 2 == 0) ? 1000 : -1000, transitionValue: (i % 2 == 0) ? -1000 : 1000, effectPartToTransition: .pitch))
        }
        self.effectsTemplateViewModels.append(EffectTemplateViewModel(type: .template, effects: transitionEffect))
        self.effectsTemplateViewModels.append(EffectTemplateViewModel(type: .template, effects: transitionEffect2))
        self.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    func setTheme(){
        guard let cells = collectionView.visibleCells as? [EffectTemplateCell] else{
            return
        }
        cells.forEach({$0.setTheme()})
     }
    
    override func didMoveToSuperview() {
        self.selectedEffectsTemplate = effectsTemplateViewModels.first(where: {$0.type == .template})
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension EffectsPicker: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.effectsTemplateViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectTemplateCell", for: indexPath) as? EffectTemplateCell else{
            return UICollectionViewCell()
        }
        cell.start(effectTemplateViewModel: effectsTemplateViewModels[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTemplate = effectsTemplateViewModels[indexPath.row]
        
        if selectedTemplate.type != .empty{
            effectsTemplateViewModels.forEach({$0.isSelected = false})
            self.selectedEffectsTemplate = effectsTemplateViewModels[indexPath.row]
        }
        else{
            self.delegate?.didClickOnCreate()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return effectsTemplateViewModels[indexPath.row].size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}


protocol EffectsPickerDelegate: AnyObject {
    func didPick(effects: Effects)
    func didClickOnCreate()
}


//Inherit from device theme protocol
extension EffectsPicker: ThemeColorChangable{
    func didChangeTheme(newTheme: DeviceTheme) {
        
    }
}
