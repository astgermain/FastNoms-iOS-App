//
//  APIReq.swift
//  EatNow
//
//  Created by Andrew St Germain on 1/24/20.
//  Copyright © 2020 Andrew St Germain. All rights reserved.
//

import Alamofire
import Foundation
import MapKit
import CoreLocation

class APIReq: NSObject {
    
    
    
    
    
    static func req(_ term: String, _ latitude: Double, _ longitude: Double, _ radius: Double, _ price: String, completion: @escaping (_ result: [String: Any]) -> Void) {
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

       
        let trimmedTerm = term.replacingOccurrences(of: " ", with: "-")
        let parsedRadius = Int(radius) * 1600
        var ifPrice = ""
        if(price != ""){
            ifPrice = "&price=\(price)"
        }
        
        struct Businesses: Codable {
            var coordinates: [Coordinates]
            var name: String
        }
        struct Coordinates: Codable {
            var longitude: Float
            var latitude: Float
        }
        
        
        AF.request("\(apiUrl)businesses/search?term=\(trimmedTerm)&latitude=\(latitude)&longitude=\(longitude)&radius=\(parsedRadius)&open_now=true\(ifPrice)", headers: headers).validate().responseJSON { closureResponse in
            response = closureResponse
            //debugPrint(closureResponse)
            switch response?.result {
                case .success(let JSON):
                    let value = JSON as! NSDictionary
                    let places = value["businesses"] as! Array<Any>
                    guard let randomPlace = places.randomElement() else{
                        print("No results")
                        return
                    }
                    let random = randomPlace as! NSDictionary
                    let randomName = random.value(forKey: "name")
                    print(randomName!)
                case .failure(let error ):
                    print(error)

                default:
                    fatalError("received non-dictionary JSON response")
            }
            
        }
        
    }
    
    static func getResult(term:String, latitude:Double, longitude:Double, radius:Double, price:String, completionHandler: @escaping (_ result: [String: Any]) -> Void) {
        req(term, latitude, longitude, radius, price, completion: completionHandler)
    }
}
        
    
    
    
    

