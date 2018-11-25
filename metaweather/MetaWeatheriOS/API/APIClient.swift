//
//  APIClient.swift
//  iXNYCodeChallenge
//
//  Created by Marcos Rodriguez on 8/5/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit

class APIClient: NSObject {
    
    static let shared = APIClient()
    var urlComponents: URLComponents = URLComponents()
    
    override init() {
        super.init()
        urlComponents.scheme = "https"
        urlComponents.host = "www.metaweather.com"
        urlComponents.path = "/api/location/search/"
    }
    
    typealias dataCompletionHandler = (_ data: [LocationSearch]?, _ response: URLResponse?, _ error: Error?) -> ()
    typealias dataLocationDetailsCompletionHandler = (_ data: Location?, _ response: URLResponse?, _ error: Error?) -> ()

    func locationSearch(query: String, completionHandler: @escaping dataCompletionHandler) {
        urlComponents.path = "/api/location/search/"

        DataManager.shared.searchHistory.append(SearchHistory(type: .query, string: query))
        urlComponents.queryItems = [URLQueryItem(name: "query", value: query)]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completionHandler(APIClient.parseSearchJSON(data: data), response, error)
            } else {
                completionHandler(nil, response, error)
            }
        }.resume()
    }
    
    func currentlocationSearch(coordinate: String?, completionHandler: @escaping dataCompletionHandler) {
        urlComponents.path = "/api/location/search/"

        var searchHistoryOptional: SearchHistory?
        if let coordinate = coordinate, !coordinate.isEmpty {
            searchHistoryOptional = SearchHistory(type: .coordinate, string: coordinate)
        } else {
            if let coordinate = LocationManager.shared.location?.coordinate {
                searchHistoryOptional = SearchHistory(type: .coordinate, string: "\(coordinate.latitude),\(coordinate.longitude)")
            }
        }
        
        guard let searchHistory = searchHistoryOptional else { return }
    
        DataManager.shared.searchHistory.append(searchHistory)
      
        urlComponents.queryItems = [URLQueryItem(name: "lattlong", value: searchHistory.string)]
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completionHandler(APIClient.parseSearchJSON(data: data), response, error)
            } else {
                completionHandler(nil, response, error)
            }
        }.resume()
    }
    
    func locationDetails(id: Int, completionHandler: @escaping dataLocationDetailsCompletionHandler) {
        urlComponents.path = "/api/location/\(String(id))/"
        urlComponents.queryItems = nil

        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completionHandler(APIClient.parseLocationJSON(data: data), response, error)
            } else {
                completionHandler(nil, response, error)
            }
        }.resume()
    }
    
     private static func parseSearchJSON(data: Data) -> [LocationSearch]? {
        do {
            let decoder = JSONDecoder()
            let parsedData = try decoder.decode([LocationSearch].self, from: data)
            return parsedData
            } catch let error {
            print(error)
            return nil
        }
    }
    
    private static func parseLocationJSON(data: Data) -> Location? {
        do {
            let decoder = JSONDecoder()
            let parsedData = try decoder.decode(Location.self, from: data)
            return parsedData
        } catch let error {
            print(error)
            return nil
        }
    }
}

extension APIClient: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
