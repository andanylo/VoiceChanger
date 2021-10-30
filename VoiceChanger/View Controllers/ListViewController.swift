//
//  ViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 18.02.2021.
//

import UIKit

class ListViewController: UIViewController {
    //MARK: - Table view
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = CollectionViewFlowLayout()
        collectionViewLayout.delegate = self
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        view.register(VoiceSoundCell.self, forCellWithReuseIdentifier: "VoiceSoundCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.alwaysBounceVertical = true
        view.allowsMultipleSelection = false
        view.allowsSelectionDuringEditing = false
        view.backgroundColor = UIColor.lightGray
        view.backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 247 / 255, alpha: 1)
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    
    //MARK: - Search controller
    private lazy var searchController: UISearchController = {
        let searchControl = UISearchController(searchResultsController: nil)
        searchControl.searchResultsUpdater = self
        searchControl.obscuresBackgroundDuringPresentation = false
        searchControl.automaticallyShowsCancelButton = true
        searchControl.hidesNavigationBarDuringPresentation = false

        return searchControl
    }()

    //MARK: - Record button
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
        button.addTarget(self, action: #selector(didClickOnRecord), for: .touchUpInside)
        button.setImage(UIImage(named: "microphone")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    //MARK: - Set editing method
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        changeSelected(voiceSoundCellModel: nil)
        guard let cells = collectionView.visibleCells as? [VoiceSoundCell] else{
            return
        }
        
        for i in cells{
            i.didChangeEditingState(isEditing: self.isEditing)
        }
        
    }

    private var movableIndexPath: IndexPath?
    
    
    private lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        return gesture
    }()
    
    ///Returns the minimum width of the cell
    private let minimumWidth: CGFloat = 300.0
    
    var numberOfVoiceSoundsInLine: Int {
        get{
            return UIDevice.current.model == "iPad" ? min(3, Int(collectionView.frame.width / minimumWidth)) : 1
        }
    }
    
    private var voiceSoundCellModels: [VoiceSoundCellModel] = []
    
    ///Returns array of voice sound cell models, that needs to be displayed, including searchbar text
    var displayedVoiceSoundCellModels: [VoiceSoundCellModel]{
        get{
            guard let searchBarText = searchController.searchBar.text else{
                return voiceSoundCellModels
            }
            if searchBarText.isEmpty{
                return voiceSoundCellModels
            }
            return voiceSoundCellModels.filter({$0.name?.lowercased().contains(searchBarText.lowercased()) == true})
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.performWithoutAnimation {
            searchController.isActive = true
            searchController.isActive = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        //Setup navigation bar
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.title = "Voice records"
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.searchController = searchController
        
        self.navigationItem.setRightBarButton(editButtonItem, animated: false)
        self.navigationController?.navigationBar.sizeToFit()

        
        let shoppingItem = UIBarButtonItem(image: UIImage(named: "shopping-bag")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(removeAdsAction))
        self.navigationItem.setLeftBarButton(shoppingItem, animated: false)
        
        voiceSoundCellModels = Variables.shared.recordList.list.map({return VoiceSoundCellModel(voiceSound: $0, listViewController: self)})
        
        
        self.view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo:  self.view.topAnchor).isActive = true//self.view.safeAreaLayoutGuide.topAnchor
        collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
       
        self.view.backgroundColor = .white
        
        self.view.addSubview(recordButton)
        
        recordButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        Player.shared.delegate = self
        
        self.view.layoutIfNeeded()
        
        let safeViewBottom = UIScreen.main.bounds.height - recordButton.frame.minY
        collectionView.contentInset.bottom = safeViewBottom + 10
        
        setTheme()
        
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    //MARK: - Settings action
    @objc func removeAdsAction(){
        presentPopUp(type: .ads, objectToTransfer: nil)
    }
    
    
    //MARK: - Layout the size of collection view cells
    override func viewDidLayoutSubviews() {
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? CollectionViewFlowLayout else{
            return
        }
        collectionViewFlowLayout.invalidateLayout()
        collectionViewFlowLayout.minimumLineSpacing = 10
        collectionView.layoutIfNeeded()
    }
    
    //MARK: - Present popup view controller
    func presentPopUp(type: PopUpController.PopUpCategory, objectToTransfer: AnyObject?){
        let popUpController = PopUpController(rootViewController: self)
        popUpController.popUpCategory = type
        popUpController.objectToTransfer = objectToTransfer
        popUpController.modalPresentationStyle = .custom
        Animator.shared.duration = 0.72
        popUpController.transitioningDelegate = self
        self.navigationController?.present(popUpController, animated: true, completion: nil)
    }
    
    @objc func didClickOnRecord(){
        presentRecorder(objectToTransfer: nil)
    }
    
    func presentEffectCreator(){
        presentPopUp(type: .effect, objectToTransfer: nil)
    }
    func presentRecorder(objectToTransfer: VoiceSound?){
        presentPopUp(type: .record, objectToTransfer: objectToTransfer)
    }
    
    //MARK: - Options for the voice sound
    func presentOptions(voiceSound: VoiceSound){
        let options = UIAlertController(title: voiceSound.name, message: nil, preferredStyle: .actionSheet)
        options.addAction(UIAlertAction(title: "Share sound", style: .default, handler: { (_) in
            
            let loadingViewController = LoadingViewController()
            loadingViewController.modalPresentationStyle = .custom
            loadingViewController.transitioningDelegate = self
            Animator.shared.duration = 0.4
            self.navigationController?.present(loadingViewController, animated: true, completion: nil)
            
            DispatchQueue.global(qos: .userInitiated).async {
                do{
                    try FileExporter.shared.exportFile(voiceSound: voiceSound, completion: { url in
                        DispatchQueue.main.async {
                            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                            activity.completionWithItemsHandler = { _, completed, _, _ in
                                loadingViewController.dismissWith(state: completed ? .loadedSuccessfully : .error)
                                try? FileManager.default.removeItem(at: url)
                            }
                            
                            if let popover = activity.popoverPresentationController, let cellIndex = self.displayedVoiceSoundCellModels.firstIndex(where: {$0.voiceSound === voiceSound}), let cell = self.collectionView.cellForItem(at: IndexPath(row: cellIndex, section: 0)){
                                popover.sourceView = cell
                                popover.sourceRect = cell.bounds
                            }
                            loadingViewController.present(activity, animated: true, completion: nil)
                        }
                    })
                    
                }
                catch{
                    print(error.localizedDescription)
                }
            }
        }))
        options.addAction(UIAlertAction(title: "Rename", style: .default, handler: { (_) in
            DispatchQueue.main.async {
                let renameAlert = UIAlertController(title: "Rename sound", message: "Enter the new name below", preferredStyle: .alert)
                var alertTextField: UITextField?
                renameAlert.addTextField { [weak voiceSound] textField in
                    textField.clearButtonMode = .always
                    textField.text = voiceSound?.name
                    alertTextField = textField
                }
                renameAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                    DispatchQueue.main.async {
                        if let newName = alertTextField?.text{
                            voiceSound.name = newName
                            guard let index = self.displayedVoiceSoundCellModels.firstIndex(where: {$0.voiceSound === voiceSound}), let cell = self.collectionView.cellForItem(at: IndexPath(row: Int(index), section: 0)) as? VoiceSoundCell else{
                                return
                            }
                            cell.changeName(newName: newName)
                        }
                    }
                }))
                renameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.navigationController?.present(renameAlert, animated: true, completion: nil)
            }
        }))
        options.addAction(UIAlertAction(title: "Rerecord", style: .default, handler: { (_) in
            DispatchQueue.main.async {
                self.presentRecorder(objectToTransfer: voiceSound)
            }
        }))
        
        options.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            DispatchQueue.main.async {
                guard let cellIndex = self.displayedVoiceSoundCellModels.firstIndex(where: {$0.voiceSound === voiceSound}), let cell = self.collectionView.cellForItem(at: IndexPath(row: cellIndex, section: 0)) else {
                    return
                }
                self.collectionViewDeleteAction(cell: cell)
            }
        }))
        
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popover = options.popoverPresentationController, let cellIndex = self.displayedVoiceSoundCellModels.firstIndex(where: {$0.voiceSound === voiceSound}), let cell = self.collectionView.cellForItem(at: IndexPath(row: cellIndex, section: 0)){
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        
        self.navigationController?.present(options, animated: true, completion: nil)
    }
    
    //MARK: - collection view rearrangement
    func startMovement(){
        guard let indexPath = collectionView.indexPathForItem(at: longPressGesture.location(in: longPressGesture.view)), self.isEditing else{
            return
        }
        changeSelected(voiceSoundCellModel: nil)
        movableIndexPath = indexPath
        collectionView.beginInteractiveMovementForItem(at: indexPath)
    }
    func updateMovement(){
        if movableIndexPath != nil{
          
            collectionView.updateInteractiveMovementTargetPosition(longPressGesture.location(in: longPressGesture.view))
        }
    }
    func endMovement(){
        if movableIndexPath != nil{
            collectionView.endInteractiveMovement()
        }
    }
    func moveModel(from: Int, to: Int){
        let object = voiceSoundCellModels[from]
        voiceSoundCellModels.remove(at: from)
        voiceSoundCellModels.insert(object, at: to)
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        Variables.shared.recordList.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
        moveModel(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        
        return proposedIndexPath
    }
  
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    @objc func longPressAction(gesture: UILongPressGestureRecognizer){
        switch gesture.state {
        case .began:
            startMovement()
        case .changed:
            updateMovement()
        case .ended:
            endMovement()
        default:
            break
        }
    }
    
    ///Did change theme of the application
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setTheme()
    }
    
    //MARK: -Set theme for views
    func setTheme(){
        if #available(iOS 13.0, *) {
            
            if self.traitCollection.userInterfaceStyle == .dark{
                Variables.shared.currentDeviceTheme = .dark
            }
            else{
                Variables.shared.currentDeviceTheme = .normal
            }
            
        } else {
            Variables.shared.currentDeviceTheme = .normal
        }
        
        collectionView.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? UIColor.white : .black
        recordButton.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .init(white: 0.1, alpha: 1)
        recordButton.tintColor = Variables.shared.currentDeviceTheme == .normal ? .black : .white
        navigationController?.navigationBar.backgroundColor = Variables.shared.currentDeviceTheme == .normal ? .white : .black
        navigationController?.navigationBar.tintColor = Variables.shared.currentDeviceTheme == .normal ? .black : .white
        view.backgroundColor = navigationController?.navigationBar.backgroundColor
        editButtonItem.tintColor = Variables.shared.currentDeviceTheme == .normal ? .init(red: 0, green: 122/255, blue: 1, alpha: 1) : .white
        navigationItem.leftBarButtonItems?.forEach({$0.tintColor = Variables.shared.currentDeviceTheme == .normal ? .init(red: 0, green: 122/255, blue: 1, alpha: 1) : .white})
        guard let cells = collectionView.visibleCells as? [VoiceSoundCell] else{
            return
        }
        for i in cells{
            i.setTheme()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        setTheme()
       
    }
    
}

//MARK: -Delegate for the search controller
extension ListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
}

//MARK: -Collection view delegate and datasource
extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource, FlowLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedVoiceSoundCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoiceSoundCell", for: indexPath) as? VoiceSoundCell else{
            return UICollectionViewCell()
        }
        
        cell.start(with: displayedVoiceSoundCellModels[indexPath.row], isEditing: self.isEditing)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, edgesForItemAt indexPath: IndexPath) -> UIEdgeInsets{
        return displayedVoiceSoundCellModels[indexPath.row].edges
    }
    func numberOfItemsInLine() -> Int{
        return self.numberOfVoiceSoundsInLine
    }
    
    func changeSelected(voiceSoundCellModel: VoiceSoundCellModel?){
        guard let collectionViewFlowLayout = collectionView.collectionViewLayout as? CollectionViewFlowLayout else{
            return
        }

        self.voiceSoundCellModels.forEach({
            if !($0 === voiceSoundCellModel){
                $0.isSelected = false
            }
        })

        collectionView.performBatchUpdates {

        } completion: { (_) in
            collectionViewFlowLayout.invalidateLayout()
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let displayedModels = displayedVoiceSoundCellModels
       
        
        return CGSize(width: displayedModels[indexPath.row].width ?? 0.0, height: displayedModels[indexPath.row].height)
    }
    
    
    ///Delete the cell with model and view model
    func collectionViewDeleteAction(cell: UICollectionViewCell?){
        let alertController = UIAlertController(title: "Are you sure?", message: "You are about to delete this sound, deleted sounds will be gone forever!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            DispatchQueue.main.async {
                Player.shared.stopPlaying(isPausing: false)
                guard let cell = cell, let indexPath = self.collectionView.indexPath(for: cell), let model = (cell as? VoiceSoundCell)?.voiceSoundCellModel, let object = model.voiceSound else{
                    return
                }
                do{
                    guard let url = object.url else{
                        return
                    }
                    try FileManager.default.removeItem(at: url)
                }
                catch{
                    
                }
            
                Variables.shared.recordList.list.removeAll(where: {$0.url == object.url})
                self.voiceSoundCellModels.removeAll(where: {$0.voiceSound?.url == object.url})
                self.collectionView.deleteItems(at: [indexPath])
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.navigationController?.present(alertController, animated: true, completion: nil)
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
        Animator.shared.firstViewController = self
        Animator.shared.secondViewController = presented
        return Animator.shared
    }
}

extension ListViewController: RecordViewControllerDelegate{
    func willSave(voiceSound: VoiceSound) {
        if let index = voiceSoundCellModels.firstIndex(where: {$0.voiceSound === voiceSound}){
            voiceSoundCellModels[index].voiceSound = voiceSound
            DispatchQueue.main.async{
                self.collectionView.reloadItems(at: [IndexPath(row: Int(index), section: 0)])
            }
            
        }
        else{
            Variables.shared.recordList.list.append(voiceSound)
            let voiceSoundModel = VoiceSoundCellModel(voiceSound: voiceSound, listViewController: self)
            voiceSoundCellModels.append(voiceSoundModel)
            if displayedVoiceSoundCellModels.contains(where: {$0 === voiceSoundModel}){
                DispatchQueue.main.async {
                    self.collectionView.insertItems(at: [IndexPath(row: self.displayedVoiceSoundCellModels.count - 1, section: 0)])
                }
            }
        }
    }
}

extension ListViewController: PlayerDelegate{
    func didUpdateCurrentTime(currentTime: TimeComponents) {
      
        guard let currentVoiceModel = findCurrentPlayingVoiceSoundCellModel() else{
            return
        }
        
        currentVoiceModel.playerViewModel?.onPlayerCurrentTimeChange?(currentTime)
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


