//
//  EffectTemplateCell.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 03.04.2021.
//

import Foundation
import UIKit


class EffectTemplateCell: UICollectionViewCell{
    var effectTemplateViewModel: EffectTemplateViewModel?
    
    private var addImage: UIButton?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        effectTemplateViewModel?.didSelect = nil
        addImage?.removeFromSuperview()
        addImage = nil
    }
    func start(effectTemplateViewModel: EffectTemplateViewModel){
        self.contentView.layer.cornerRadius = self.contentView.frame.width / 2
        self.effectTemplateViewModel = effectTemplateViewModel
        if effectTemplateViewModel.type == .template{
            self.contentView.layer.shadowPath = UIBezierPath(roundedRect: self.contentView.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
            self.contentView.layer.shadowRadius = 3
            self.contentView.layer.shadowOffset = .zero
            self.contentView.layer.shadowOpacity = 0.3
            self.contentView.layer.shadowColor = UIColor.black.cgColor
            
            self.contentView.layer.borderWidth = effectTemplateViewModel.isSelected ? 3 : 0.5
            self.contentView.layer.borderColor = effectTemplateViewModel.isSelected ? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor : UIColor.lightGray.cgColor
        }
        else{
            addImage = UIButton(type: .contactAdd)
            addImage?.isUserInteractionEnabled = false
            addImage?.translatesAutoresizingMaskIntoConstraints = false
            addImage?.tintColor = UIColor.gray
            self.contentView.addSubview(addImage!)
            
            addImage?.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            addImage?.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            addImage?.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            addImage?.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        }
        
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .white
        
        effectTemplateViewModel.didSelect = { bool in
            DispatchQueue.main.async {
                if effectTemplateViewModel.type == .template{
                    self.contentView.layer.borderWidth = effectTemplateViewModel.isSelected ? 3 : 0.5
                    self.contentView.layer.borderColor = effectTemplateViewModel.isSelected ? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor : UIColor.lightGray.cgColor
                }
            }
        }
    }
}


//Inherit from device theme protocol
extension EffectTemplateCell: ThemeColorChangable{
    func didChangeTheme(newTheme: DeviceTheme) {
        
    }
}
