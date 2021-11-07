//
//  SettingsViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 29.10.2021.
//

import Foundation
import UIKit
import StoreKit

//Ads remover view controller
class AdsRemoverController: UIViewController, PopUpChildProtocol{
    func setTheme() {
        titleLabel.textColor = Variables.shared.currentDeviceTheme == .normal ? .black : .white
        priceLabel.textColor = .darkGray
        buyButton.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .init(white: 0.8, alpha: 1) : .init(white: 0.2, alpha: 1)
        restoreButton.setTitleColor(Variables.shared.currentDeviceTheme == .normal ? .init(red: 0, green: 122/255, blue: 1, alpha: 1) : .white, for: .normal)
    }
    
    var priceLabelViewModel: PriceLabelViewModel = PriceLabelViewModel()
    
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
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: label.frame.width).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.frame.height).isActive = true
        return label
    }()
    
    //MARK: - Restore button
    lazy var restoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.init(red: 0, green: 122/255, blue: 1, alpha: 1), for: .normal)
        button.setTitle("Already purchased? Click to restore", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .light)
        button.addTarget(self, action: #selector(restoreButtonClicked), for: .touchUpInside)
        button.sizeToFit()
        button.heightAnchor.constraint(equalToConstant: button.frame.height).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: button.frame.width).isActive = true
        return button
    }()
    
    //MARK: - Loading view controller
    var loadingViewController = LoadingViewController()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if !IAP.shared.isEmpty(){
            self.didFecth(products: IAP.shared.products)
        }
        else{
            IAP.shared.setProductIds(ids: ["andanylo.VoiceChanger.RemoveAds"])
            IAP.shared.fetchAvailableProducts()
        }
        
        
        IAP.shared.delegate = self
        
        self.view.addSubview(restoreButton)
        restoreButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15).isActive = true
        restoreButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.view.addSubview(buyButton)
        buyButton.bottomAnchor.constraint(equalTo: restoreButton.topAnchor, constant: 0).isActive = true
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
        if IAP.shared.canMakePurchases(){
            IAP.shared.purchase()
            loadLoadingViewController()
        }
    }
    
    func loadLoadingViewController(){
        loadingViewController = LoadingViewController()
        loadingViewController.modalPresentationStyle = .custom
        loadingViewController.transitioningDelegate = self
        Animator.shared.duration = 0.4
        self.present(loadingViewController, animated: true, completion: nil)
    }
    
    @objc func restoreButtonClicked(){
        IAP.shared.restorePurchase()
        loadLoadingViewController()
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

extension AdsRemoverController: IAPDelegate{
    func finish(state: IAPState) {
        DispatchQueue.main.async {
            switch state {
            case .restored:
                self.loadingViewController.dismissWith(state: .loadedSuccessfully)
                self.dismiss(animated: true, completion: nil)
            case .purchased:
                self.loadingViewController.dismissWith(state: .loadedSuccessfully)
                self.dismiss(animated: true, completion: nil)
            case .failed:
                self.loadingViewController.dismissWith(state: .error)
            default:
                break
            }
        }
    }
    
    func didFecth(products: [SKProduct]) {
        DispatchQueue.main.async {
            self.priceLabel.text = self.priceLabelViewModel.getTextForLabel(for: products.first)
            self.priceLabel.sizeToFit()
        }
        
    }
    
    
}
