//
//  SearchHistory.swift
//  MetaWeatheriOS
//
//  Created by Marcos Rodriguez on 8/6/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import Foundation

struct SearchHistory {
    enum SearchHistoryType {
        case query, coordinate
    }
    
    let type: SearchHistoryType
    let string: String
    let timestamp: Date = Date()
}
