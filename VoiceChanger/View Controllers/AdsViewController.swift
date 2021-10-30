//
//  SettingsViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 29.10.2021.
//

import Foundation
import UIKit

//Ads remover view controller
class AdsRemoverController: UIViewController, PopUpChildProtocol{
    func setTheme() {
        titleLabel.textColor = Variables.shared.currentDeviceTheme == .normal ? .black : .white
        priceLabel.textColor = Variables.shared.currentDeviceTheme == .normal ? .lightGray : .darkGray
        buyButton.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .init(white: 0.8, alpha: 1) : .init(white: 0.2, alpha: 1)
    }
    
    //MARK: -Buy button
    lazy var buyButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .init(white: 0.8, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Buy", for: .normal)
        let heightConstant: CGFloat = 35
        button.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
        button.layer.cornerRadius = heightConstant / 3
        button.addTarget(self, action: #selector(buyButtonClicked), for: .touchUpInside)
        return button
    }()
    
    //MARK: -Title label
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Remove ads"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.frame.height).isActive = true
        
        return label
    }()
    
    //MARK: - Price label
    
    lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "$?.??"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: label.frame.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.frame.height).isActive = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(buyButton)
        buyButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15).isActive = true
        buyButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25).isActive = true
        buyButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25).isActive = true
        
        self.view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
      
        
        self.view.addSubview(priceLabel)
        priceLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        priceLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    //MARK: - Buy button clicked
    @objc func buyButtonClicked(){
        let loadingViewController = LoadingViewController()
        loadingViewController.modalPresentationStyle = .custom
        loadingViewController.transitioningDelegate = self
        Animator.shared.duration = 0.4
        self.present(loadingViewController, animated: true, completion: nil)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
}

extension AdsRemoverController: UIViewControllerTransitioningDelegate{
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Animator.shared.presenting = false
        
        Animator.shared.firstViewController = self
        Animator.shared.secondViewController = dismissed
        return Animator.shared
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Animator.shared.presenting = true
        Animator.shared.firstViewController = self
        Animator.shared.secondViewController = presented
        return Animator.shared
    }
}

