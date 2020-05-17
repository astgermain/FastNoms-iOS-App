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
import Contacts

class APIReq: NSObject {
    
    
    
    static func openMapForPlace(tlatitude:Double, tlongitude:Double, pName:String, a1:String, city:String, state:String, zip:String) {

        let latitude: CLLocationDegrees = tlatitude
        let longitude: CLLocationDegrees = tlongitude

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let address = [CNPostalAddressStreetKey: a1,
        CNPostalAddressCityKey: city,
        CNPostalAddressStateKey: state,
        CNPostalAddressPostalCodeKey: zip]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: address)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = pName
        mapItem.openInMaps(launchOptions: options)
    }
    
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
                    //let rValue = JSON as! [String: Any]
                    let value = JSON as! NSDictionary
                    let places = value["businesses"] as! Array<Any>
                    guard let randomPlace = places.randomElement() else{
                        print("No results")
                        return
                    }
                    let random = randomPlace as! NSDictionary
                    completion(random as! [String : Any])
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
        
    
    
    
    

