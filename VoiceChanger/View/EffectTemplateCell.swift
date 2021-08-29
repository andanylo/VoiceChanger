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
    
    private var selectedColor: UIColor{
        get{
            return Variables.shared.currentDeviceTheme == .normal ? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1) : .white
        }
    }
    private var standardColor: UIColor{
        get{
            return Variables.shared.currentDeviceTheme == .normal ? UIColor.lightGray : .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.contentView.backgroundColor = .white
        self.contentView.layer.shadowPath = nil
        self.contentView.layer.shadowRadius = 0
        self.contentView.layer.borderWidth = 0
        self.contentView.layer.borderColor = nil
        addImage?.removeFromSuperview()
        addImage = nil
    }
    func start(effectTemplateViewModel: EffectTemplateViewModel){
       
        self.contentView.layer.cornerRadius = effectTemplateViewModel.size.width / 2
        self.effectTemplateViewModel = effectTemplateViewModel
        if effectTemplateViewModel.type == .template{
            self.contentView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: effectTemplateViewModel.size.width, height: effectTemplateViewModel.size.height), cornerRadius: self.contentView.layer.cornerRadius).cgPath
            self.contentView.layer.shadowRadius = 3
            self.contentView.layer.shadowOffset = .zero
            self.contentView.layer.shadowOpacity = 0.3
            self.contentView.layer.shadowColor = UIColor.black.cgColor
            self.contentView.layer.borderWidth = effectTemplateViewModel.isSelected ? 3 : 0.5
            self.contentView.layer.borderColor = effectTemplateViewModel.isSelected ? selectedColor.cgColor : standardColor.cgColor
            
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
            
            self.contentView.backgroundColor = .clear
        }
        
        
        self.backgroundColor = .clear
        self.effectTemplateViewModel?.didSelect = { [weak self] bool in
            DispatchQueue.main.async {
                if effectTemplateViewModel.type == .template{
                    self?.contentView.layer.borderWidth = effectTemplateViewModel.isSelected ? 3 : 0.5
                    self?.contentView.layer.borderColor = effectTemplateViewModel.isSelected ? self?.selectedColor.cgColor : self?.standardColor.cgColor
                }
            }
        }
        self.effectTemplateViewModel?.didSelect?(self.effectTemplateViewModel?.isSelected == true)
        
        setTheme()
    }
    
    func setTheme(){
        if self.contentView.backgroundColor != .clear{
            self.contentView.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .darkGray
        }
        
        self.contentView.layer.borderColor = effectTemplateViewModel?.isSelected == true ? selectedColor.cgColor : standardColor.cgColor
        addImage?.tintColor = Variables.shared.currentDeviceTheme == .normal ? .gray : .white
    }
}

