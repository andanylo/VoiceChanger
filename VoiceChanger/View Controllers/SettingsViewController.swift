//
//  SettingsViewController.swift
//  VoiceChanger
//
//  Created by Danil Andriuschenko on 29.10.2021.
//

import Foundation
import UIKit

//Settings view controller
class SettingsViewController: UIViewController{
    
    //MARK: - Table view
    lazy var tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        return table
    }()
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
    
}
