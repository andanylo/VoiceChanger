//
//  ViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import UIKit

class ListViewController: UIViewController {
    ///Table view
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        view.register(VoiceSoundCell.self, forCellWithReuseIdentifier: "VoiceSoundCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.allowsMultipleSelection = false
        view.allowsSelectionDuringEditing = false
        view.backgroundColor = UIColor.lightGray
        view.contentInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        view.backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)
        
        return view
    }()
    
    ///Navigation bar
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.barStyle = .default
        navBar.isTranslucent = false
        navBar.sizeToFit()
        navBar.heightAnchor.constraint(equalToConstant: navBar.frame.height).isActive = true
        let navItem = UINavigationItem(title: "Title")
        navBar.setItems([navItem], animated: false)
        return navBar
    }()
    
    var voiceSoundCellModels: [VoiceSoundCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstVoiceTest = VoiceSound(lastPathComponent: "test1.m4a")
        firstVoiceTest.name = "TESTING1"
        let secondVoiceTest = VoiceSound(lastPathComponent: "test2.m4a")
        secondVoiceTest.name = "TESTING2"
        Variables.shared.recordList.list = [firstVoiceTest, secondVoiceTest]
        
        voiceSoundCellModels = Variables.shared.recordList.list.map({return VoiceSoundCellModel(voiceSound: $0)})
        
        self.view.addSubview(navigationBar)

        navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        self.view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0.5).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
       
        self.view.backgroundColor = .white
        
        
    }
    
    override func viewDidLayoutSubviews() {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else{
            return
        }
        collectionViewFlowLayout.invalidateLayout()
        collectionViewFlowLayout.itemSize = CGSize(width: self.view.frame.width - 20, height: 70)
        collectionViewFlowLayout.minimumLineSpacing = 10
        collectionView.layoutIfNeeded()
    }
    
    @objc func presentRecorder(){
        let recordViewController = RecordViewController()
        recordViewController.modalPresentationStyle = .overCurrentContext
        Animator.shared.duration = 0.72
        recordViewController.transitioningDelegate = self
        self.present(recordViewController, animated: true, completion: nil)
    }
}

///Collection view delegate and datasource
extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Variables.shared.recordList.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoiceSoundCell", for: indexPath) as? VoiceSoundCell else{
            return UICollectionViewCell()
        }
        cell.start(with: voiceSoundCellModels[indexPath.row])
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else{
            return
        }
        let isSelected = voiceSoundCellModels[indexPath.row].isSelected
        voiceSoundCellModels[indexPath.row].isSelected = isSelected == false ? true : false
        collectionViewFlowLayout.invalidateLayout()
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - voiceSoundCellModels[indexPath.row].edges.left - voiceSoundCellModels[indexPath.row].edges.right, height: voiceSoundCellModels[indexPath.row].height)
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
