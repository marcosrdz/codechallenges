//
//  DetailTableViewController.swift
//  MetaWeatheriOS
//
//  Created by Marcos Rodriguez on 8/6/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {

    static let segueIdentifier = "DetailTableViewControllerSegueIdentifier"
    var dataSource: Location?
    private let dateFormatter = DateFormatter()
    private let dateFormatterMedium = DateFormatter()
    private let numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatterMedium.dateStyle = .medium
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        title = dataSource?.title
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.consolidatedWeather.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DetailViewControllerTableViewCell
        let locationData = dataSource?.consolidatedWeather[indexPath.row]
        cell.summaryLabel.text = locationData?.weather_state_name
        
        if let minTemp = locationData?.min_temp, let maxTemp = locationData?.max_temp {
            cell.minTempLabel.text = String(minTemp)
            cell.maxTempLabel.text = String(maxTemp)
            cell.windSpeedLabel.text = numberFormatter.string(from: NSNumber(value: locationData?.wind_speed ?? 0))
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let applicableDate = dataSource?.consolidatedWeather[section].applicable_date,
            let date = dateFormatter.date(from: applicableDate)
            else { return nil }
        
        return dateFormatterMedium.string(from: date)

    }

}
