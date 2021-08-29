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
    
    var effectPickerViewModel: EffectPickerViewModel!{
        didSet{
            self.collectionView.reloadData()
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
    
    
    init(effectPickerViewModel: EffectPickerViewModel){
        
        super.init(frame: CGRect.zero)
        
        self.effectPickerViewModel = effectPickerViewModel
        
        self.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        setTheme()
    }
    init(){
        super.init(frame: CGRect.zero)
    }
    func setTheme(){
        guard let cells = collectionView.visibleCells as? [EffectTemplateCell] else{
            return
        }
        cells.forEach({$0.setTheme()})
    }
    
    override func didMoveToSuperview() {
        self.effectPickerViewModel.selectedEffectsTemplate = self.effectPickerViewModel.effectsTemplateViewModels.first(where: {$0.type == .template})
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension EffectsPicker: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.effectPickerViewModel.effectsTemplateViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectTemplateCell", for: indexPath) as? EffectTemplateCell else{
            return UICollectionViewCell()
        }
        
        cell.start(effectTemplateViewModel: self.effectPickerViewModel.effectsTemplateViewModels[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTemplate = self.effectPickerViewModel.effectsTemplateViewModels[indexPath.row]
        
        if selectedTemplate.type != .empty{
            self.effectPickerViewModel.selectedEffectsTemplate = self.effectPickerViewModel.effectsTemplateViewModels[indexPath.row]
        }
        else{
            self.effectPickerViewModel.didClickOnCreate?()
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.effectPickerViewModel.effectsTemplateViewModels[indexPath.row].size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
