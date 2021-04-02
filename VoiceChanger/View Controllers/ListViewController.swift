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
        navItem.setLeftBarButton(editButtonItem, animated: false)
        return navBar
    }()

    ///Record button
    private lazy var recordButton: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.frame.size = CGSize(width: 50, height: 50)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: 25).cgPath
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.6
        button.addTarget(self, action: #selector(presentRecorder), for: .touchUpInside)
        return button
    }()
    
    ///Set editing method
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        guard let cells = collectionView.visibleCells as? [VoiceSoundCell] else{
            return
        }
        for i in cells{
            i.didChangeEditingState(isEditing: self.isEditing)
        }
        
    }

    
    var voiceSoundCellModels: [VoiceSoundCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        voiceSoundCellModels = Variables.shared.recordList.list.map({return VoiceSoundCellModel(voiceSound: $0, listViewController: self)})
        
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
        
        self.view.addSubview(recordButton)
        
        recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        Player.shared.delegate = self
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
        recordViewController.delegate = self
        recordViewController.transitioningDelegate = self
        self.present(recordViewController, animated: true, completion: nil)
    }
}

///Collection view delegate and datasource
extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voiceSoundCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoiceSoundCell", for: indexPath) as? VoiceSoundCell else{
            return UICollectionViewCell()
        }
        cell.start(with: voiceSoundCellModels[indexPath.row], isEditing: self.isEditing)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else{
            return
        }
        let isSelected = voiceSoundCellModels[indexPath.row].isSelected
        self.voiceSoundCellModels.forEach({$0.isSelected = false})
        self.voiceSoundCellModels[indexPath.row].isSelected = isSelected == false ? true : false
        collectionView.performBatchUpdates {

        } completion: { (_) in
            collectionViewFlowLayout.invalidateLayout()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - voiceSoundCellModels[indexPath.row].edges.left - voiceSoundCellModels[indexPath.row].edges.right, height: voiceSoundCellModels[indexPath.row].height)
    }
    func collectionViewDeleteAction(cell: UICollectionViewCell?){
        guard let cell = cell, let indexPath = collectionView.indexPath(for: cell) else{
            return
        }
        do{
            guard let url = Variables.shared.recordList.returnObject(at: indexPath.row)?.url else{
                return
            }
            try FileManager.default.removeItem(at: url)
        }
        catch{
            
        }
        Variables.shared.recordList.list.remove(at: indexPath.row)
        self.voiceSoundCellModels.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
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

extension ListViewController: RecordViewControllerDelegate{
    func willSave(voiceSound: VoiceSound) {
        Variables.shared.recordList.list.append(voiceSound)
        voiceSoundCellModels.append(VoiceSoundCellModel(voiceSound: voiceSound, listViewController: self))
        DispatchQueue.main.async {
            self.collectionView.insertItems(at: [IndexPath(row: self.voiceSoundCellModels.count - 1, section: 0)])
        }
    }
}

extension ListViewController: PlayerDelegate{
    func didUpdateTimer(timer: CustomTimer) {
      
        guard let currentVoiceModel = findCurrentPlayingVoiceSoundCellModel() else{
            return
        }
        
        currentVoiceModel.playerViewModel?.onPlayerTimerChange?(timer)
    }
    
    func didPlayerStopPlaying() {
        changeThePlayerState(isPlaying: false)
    }
    
    func didPlayerStartPlaying() {
        changeThePlayerState(isPlaying: true)
    }
    private func changeThePlayerState(isPlaying: Bool){
        guard let currentVoiceModel = findCurrentPlayingVoiceSoundCellModel() else{
            return
        }
        currentVoiceModel.playerViewModel?.onPlayStateChange?(isPlaying)
    }
    private func findCurrentPlayingVoiceSoundCellModel() -> VoiceSoundCellModel?{
        guard let currentVoiceModel = voiceSoundCellModels.first(where: {$0.voiceSound?.fullPath == Player.shared.currentVoiceSound?.fullPath && $0.voiceSound?.fullPath.isEmpty == false}) else{
            return nil
        }
        return currentVoiceModel
    }
    
}
