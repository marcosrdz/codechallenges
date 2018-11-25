//
//  APIClient.swift
//  TodosCodeChallenge
//
//  Created by Marcos Rodriguez on 8/13/18.
//  Copyright © 2018 Marcos Rodríguez Vélez. All rights reserved.
//

import UIKit

class APIClient: NSObject {
    
    static let shared = APIClient()
    var urlComponents: URLComponents = URLComponents()
    
    override init() {
        super.init()
        urlComponents.scheme = "https"
        urlComponents.host = "jsonplaceholder.typicode.com"
        urlComponents.path = "/todos/"
    }
    
    typealias dataCompletionHandler = (_ data: [Todo]?, _ response: URLResponse?, _ error: Error?) -> ()

    func fetchTodos(for userId: String?, completionHandler: @escaping dataCompletionHandler) {
        if let userId = userId {
            urlComponents.queryItems = [URLQueryItem(name: "userId", value: userId)]
        }
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completionHandler(APIClient.parseTodoJSON(data: data), response, error)
            } else {
                completionHandler(nil, response, error)
            }
        }.resume()
    }
    
     private static func parseTodoJSON(data: Data) -> [Todo]? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let parsedData = try decoder.decode([Todo].self, from: data)
            return parsedData
        } catch let error {
            print(error)
            return nil
        }
    }
}
