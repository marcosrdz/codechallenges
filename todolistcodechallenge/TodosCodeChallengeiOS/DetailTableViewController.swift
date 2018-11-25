//
//  DetailTableViewController.swift
//  TodosCodeChallengeiOS
//
//  Created by Marcos Rodriguez on 8/13/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    static let segueIdentifier = "DetailTableViewControllerSegueIdentifier"
    var dataSource: [Todo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Todo List"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailViewControllerTableViewCell
        guard let todo = dataSource?[indexPath.row] else { return cell }
        
        cell.idLabel.text = String(todo.id)
        cell.completedLabel.text = todo.completed ? "Yes" : "No"
        cell.titleLabel.text = todo.title

        return cell
    }

}
