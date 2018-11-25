//
//  SplitViewController.swift
//  TodosCodeChallenge
//
//  Created by Marcos Rodriguez on 8/6/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {

    override func viewDidLoad() {
        delegate = self
        preferredDisplayMode = .allVisible
    }
    
}

extension SplitViewController: UISplitViewControllerDelegate {
    
    func splitViewController(
        _ splitViewController: UISplitViewController,
        collapseSecondary secondaryViewController: UIViewController,
        onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
}
