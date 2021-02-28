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
//
        return UITableView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.view.backgroundColor = .white
    }


}

