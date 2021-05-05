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
        Effects(speed: 1, pitch: 0, distortion: 0, reverb: 30),
        
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
    
    weak var delegate: EffectsPickerDelegate?
    
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
        
        self.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
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
