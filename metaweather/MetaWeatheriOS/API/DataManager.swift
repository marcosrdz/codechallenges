//
//  DataManager.swift
//  iXNYCodeChallenge
//
//  Created by Marcos Rodriguez on 8/5/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit

// Would've used Core Data but there weren't any data persistance expectations
class DataManager {
    static let shared: DataManager = DataManager()
    var array: [LocationSearch] = [LocationSearch]()
    var searchHistory: [SearchHistory] = [SearchHistory]()
}
