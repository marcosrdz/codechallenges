//
//  MasterTableViewController.swift
//  iXNYCodeChallenge
//
//  Created by Marcos Rodriguez on 8/4/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit
import CoreLocation

class MasterTableViewController: UITableViewController {
    
    var dataSource: [LocationSearch] = [LocationSearch]()
    var searchController: UISearchController = UISearchController(searchResultsController: nil)
    var searchResults: [SearchHistory] = [SearchHistory]()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let dateFormatter = DateFormatter()
    @IBOutlet weak var useMyLocationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        LocationManager.shared.delegate = self
        addSearchBar()
        addActivityIndicator()
        // If we are on an iPad, show the detail view controller. If we don't do this, it'll show an empty detail view controller.
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            performSegue(withIdentifier: DetailTableViewController.segueIdentifier, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DetailTableViewController.segueIdentifier {
            let navigationController = segue.destination as? UINavigationController
            (navigationController?.topViewController as? DetailTableViewController)?.dataSource = sender as? Location
        }
    }
    
    @IBAction func myLocationButtonTapped(_ sender: UIBarButtonItem) {
        LocationManager.shared.requestLocationAuthorization()
    }
    
    // MARK: - Private functions
    
    private func addSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search by entering a location..."
        tableView.tableHeaderView = searchController.searchBar
        searchController.definesPresentationContext = true
    }
    
    private func addActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    private func setOutletsUsedForSearching(enabled: Bool) {
        searchController.searchBar.isUserInteractionEnabled = enabled
        useMyLocationButton.isEnabled = enabled
        tableView.isUserInteractionEnabled = enabled
        enabled ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.alpha = enabled ? 1.0 : 0.5
                self?.searchController.searchBar.alpha = enabled ? 1.0 : 0.5
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? searchResults.count : dataSource.count
    }
    
    func fetchQueryData(query: String, type: SearchHistory.SearchHistoryType = .query) {
        activityIndicator.startAnimating()
        setOutletsUsedForSearching(enabled: false)
        
        APIClient.shared.locationSearch(query: query) { [weak self] (data, response, error) in
            if let data = data {
                self?.dataSource.removeAll()
                self?.dataSource = data
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activityIndicator.stopAnimating()
                self?.setOutletsUsedForSearching(enabled: true)
            }
        }
    }

    func fetchCoordinatesData() {
        activityIndicator.startAnimating()
        setOutletsUsedForSearching(enabled: false)
        
        if CLLocationManager.locationServicesEnabled() {
            LocationManager.shared.requestLocation(completionHandler: { [weak self] in
                var coordinate: String? = nil
                
                if let indexPath = self?.tableView.indexPathForSelectedRow {
                    coordinate = self?.searchResults[indexPath.row].string
                }
                
                APIClient.shared.currentlocationSearch(coordinate: coordinate, completionHandler: { [weak self] (data, urlResponse, error) in
                    if let data = data {
                        self?.dataSource.removeAll()
                        self?.dataSource = data
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                        self?.activityIndicator.stopAnimating()
                        self?.setOutletsUsedForSearching(enabled: true)
                    }
                })
            })
        }
    }
    
    func fetchLocationDetails(id: Int) {
        activityIndicator.startAnimating()
        setOutletsUsedForSearching(enabled: false)
        
        APIClient.shared.locationDetails(id: id) { [weak self] (location, response, error) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.setOutletsUsedForSearching(enabled: true)
                self?.performSegue(withIdentifier: DetailTableViewController.segueIdentifier, sender: location)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch searchController.isActive {
        case true:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
            
            // Need to reset to an empty string in case of really fast scrolling
            cell.textLabel?.text = ""
            
            let historySearch = searchResults[indexPath.row]
            
            cell.textLabel?.text = historySearch.string
            cell.detailTextLabel?.text = dateFormatter.string(for: historySearch.timestamp)
            
            
            return cell
        case false:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            
            // Need to reset to an empty string in case of really fast scrolling
            cell.detailTextLabel?.text = ""
            cell.textLabel?.text = ""
            
            // Get the object in the array
            let locationSearch = dataSource[indexPath.row]
            
            var title = ""
            
            if let locationTitle = locationSearch.title {
                title = locationTitle
            }
            
            if let locationType = locationSearch.location_type {
                title = "\(title) (\(locationType))"
            }
            
            cell.textLabel?.text = title
            
            if let woeid = locationSearch.woeid {
                cell.detailTextLabel?.text = String(woeid)
            }
            
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch searchController.isActive {
        case true:
            let searchResult = searchResults[indexPath.row]
            switch searchResult.type {
                case .coordinate:
                    fetchCoordinatesData()
                case .query:
                    fetchQueryData(query: searchResult.string)
            }
        case false:
            if let woeid = dataSource[indexPath.row].woeid {
                fetchLocationDetails(id: woeid)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        searchController.isActive = false
    }

}

extension MasterTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchResults = DataManager.shared.searchHistory.filter { (searchHistory) -> Bool in
                return searchHistory.string.lowercased().contains(searchText.lowercased())
            }
        } else {
            searchResults = DataManager.shared.searchHistory
        }
        tableView.reloadData()
    }
    
}

extension MasterTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchBarText = searchBar.text, !searchBarText.isEmpty {
            searchController.isActive = false
            fetchQueryData(query: searchBarText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
}

extension MasterTableViewController: LocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            fetchCoordinatesData()
        } else if (status == .denied) {
            useMyLocationButton.isEnabled = false
        } else if (status == .notDetermined) {
            useMyLocationButton.isEnabled = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let errorAlert = UIAlertController(title: "Location", message: "We were unable to obtain your location. Please, make sure you authorized us to obtain it.", preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(errorAlert, animated: true, completion: nil)
        setOutletsUsedForSearching(enabled: true)
    }
    
}
