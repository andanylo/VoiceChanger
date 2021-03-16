//
//  ViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import UIKit

class ListViewController: UIViewController {

    
    private lazy var tableView: UITableView = {
//        let view = UITableView()
//        view.register(, forCellReuseIdentifier: )
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.dataSource = self
//        view.delegate = self
//        view.allowsMultipleSelection = false
//        view.allowsSelectionDuringEditing = false

        return UITableView()
    }()
    private lazy var presentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Present", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        button.widthAnchor.constraint(equalToConstant: button.frame.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.frame.height).isActive = true
        button.addTarget(self, action: #selector(presentRecorder), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(presentButton)
        
        presentButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        presentButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
        self.view.backgroundColor = .white
        
        
    }
    @objc func presentRecorder(){
        let recordViewController = RecordViewController()
        recordViewController.modalPresentationStyle = .overCurrentContext
        Animator.shared.duration = 0.72
        recordViewController.transitioningDelegate = self
        self.present(recordViewController, animated: true, completion: nil)
    }
}

extension ListViewController: UIViewControllerTransitioningDelegate{
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Animator.shared.presenting = false
        
        Animator.shared.firstViewController = self
        Animator.shared.secondViewController = dismissed
        return Animator.shared
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        Animator.shared.presenting = true
        Animator.shared.firstViewController = source
        Animator.shared.secondViewController = presented
        return Animator.shared
    }
}
