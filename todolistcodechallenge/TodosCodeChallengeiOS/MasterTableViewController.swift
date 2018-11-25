//
//  MasterTableViewController.swift
//  TodosCodeChallenge
//
//  Created by Marcos Rodriguez on 8/13/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit

class MasterTableViewController: UITableViewController {
    
    var dataSource: [(key: String, value: [Todo])] = [(key: String, value: [Todo])]()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        addActivityIndicator()
        // If we are on an iPad, show the detail view controller. If we don't do this, it'll show an empty detail view controller.
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            performSegue(withIdentifier: DetailTableViewController.segueIdentifier, sender: nil)
        }
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DetailTableViewController.segueIdentifier {
            let navigationController = segue.destination as? UINavigationController
            (navigationController?.topViewController as? DetailTableViewController)?.dataSource = sender as? [Todo]
        }
    }
    
    // MARK: - Private functions
    
    private func addActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    private func setOutletsEnabled(enabled: Bool) {
        tableView.isUserInteractionEnabled = enabled
        enabled ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.alpha = enabled ? 1.0 : 0.5
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func fetchData() {
        activityIndicator.startAnimating()
        setOutletsEnabled(enabled: false)
        
        APIClient.shared.fetchTodos(for: nil) { [weak self] (data, response, error) in
            if let data = data {
                self?.dataSource.removeAll()
                
                var unsortedDataSource: [String: [Todo]] = [String: [Todo]]()
                for todo in data {
                    if unsortedDataSource[String(todo.userId)] == nil {
                        unsortedDataSource[String(todo.userId)] = [Todo]()
                    }
                    unsortedDataSource[String(todo.userId)]?.append(todo)
                }
                
                let sortedData = unsortedDataSource.sorted(by: { (first: (key: String, value: [Todo]), second: (key: String, value: [Todo])) -> Bool in
                    first.value.filter({!$0.completed}).count > second.value.filter({!$0.completed}).count
                })
                
                self?.dataSource = sortedData
            }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.setOutletsEnabled(enabled: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        
        // Need to reset to an empty string in case of really fast scrolling
        cell.detailTextLabel?.text = ""
        cell.textLabel?.text = ""

        // Get the object in the array
        let todo = dataSource[indexPath.section].value.first
        
        var title = ""
        if let userId = todo?.userId {
            title = "User ID: \(String(userId))"
        }
        
        let count = dataSource[indexPath.section].value.filter({!$0.completed}).count
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = "Incomplete: \(String(count))"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: DetailTableViewController.segueIdentifier, sender: dataSource[indexPath.section].value)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
