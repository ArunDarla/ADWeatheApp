//
//  APIRequest.swift
//  ADWeatherApp
//
//  Created by VIPadm on 24/04/21.
//

import Foundation

class APIRequestClass {
    //Singleton declaration
    static let shared = APIRequestClass()
    
    private init() {}

    func APIRequestWithWeatherUrl(url: String, completionHandler: @escaping ((Result<Data, Error>) -> ())){
        
        guard let url = URL(string: url) else {
            
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "API not validated "])
            return completionHandler(.failure(error))
        }
        
        let urlReq = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        
        URLSession.shared.dataTask(with: urlReq) { (data, response, error) in
            
            if error == nil {
                guard let data = data else { return }
                completionHandler(.success(data))
            }
            else {
                completionHandler(.failure(error!))
            }
        }.resume()
        
    }
    
}
