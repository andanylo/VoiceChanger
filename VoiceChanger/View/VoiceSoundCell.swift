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
    
    ////Voice sound cell model, that updates the cell after setter
    var voiceSoundCellModel: VoiceSoundCellModel?{
        didSet{
            nameLabel.text = voiceSoundCellModel?.name
        }
    }
    
    ///Change the shadow path on bounds change
    override var bounds: CGRect{
        didSet{
            self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.removeFromSuperview()
    }
    
    
    func start(with voiceSoundCellModel: VoiceSoundCellModel?){
        
        self.backgroundColor = .white
        
        self.layer.cornerRadius = 10
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        
        self.addSubview(nameLabel)
        
        nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        
        self.voiceSoundCellModel = voiceSoundCellModel
    }
}
