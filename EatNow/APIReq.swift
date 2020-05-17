//
//  APIReq.swift
//  EatNow
//
//  Created by Andrew St Germain on 1/24/20.
//  Copyright © 2020 Andrew St Germain. All rights reserved.
//

import Alamofire
import Foundation


class APIReq: NSObject {
    
    
    
    static func req(_ term: String, _ location: String, _ radius: Double, completion: @escaping (_ result: [String: Any]) -> Void) {
        //Sends authorization header with API Key
        //TODO:
        //Find way to store API Key in Keychain
        
        let apiUrl = "https://api.yelp.com/v3/"
        
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: "bq-AvSxuPq15GuAXWqzP6Z3U_vFpSAMknca9iYe8NfHJu2FrqmgZLxXRBDu1BONZzA9zhr9QONyt64O3GRPmAlFEDXCMRdMENRPW99ea6z0IMEBgzrZ4zENc-sgqXnYx"),
            .accept("application/json")
        ]
        //TODO:
        //Find way to dynamically create all links with search functions etc
        //Find way to parse data from request
        //Find way to open maps
        //Find way to grab random result within radius of current location
        //Find way to get current location
        
        

        var response: DataResponse<Any, AFError>?

       
        let trimmedLocation = location.replacingOccurrences(of: " ", with: "-")
        let trimmedTerm = term.replacingOccurrences(of: " ", with: "-")
        let parsedRadius = Int(radius)
        //debugPrint(parsedRadius)
        AF.request("\(apiUrl)businesses/search?term=\(trimmedTerm)&location=\(trimmedLocation)&radius=\(parsedRadius)", headers: headers).validate().responseJSON { closureResponse in
            response = closureResponse
            //debugPrint(response)
            switch response?.result {
                case .success(let value as [String: Any]):
                    completion(value)

                case .failure(let error ):
                    print(error)

                default:
                    fatalError("received non-dictionary JSON response")
            }
            
        }
        
    }
    
    static func getResult(term:String, location:String, radius:Double, completionHandler: @escaping (_ result: [String: Any]) -> Void) {
        req(term, location, radius, completion: completionHandler)
    }
}
        
    
    
    
    

