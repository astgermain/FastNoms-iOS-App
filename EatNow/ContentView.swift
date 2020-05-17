//
//  ContentView.swift
//  EatNow
//
//  Created by Andrew St Germain on 1/24/20.
//  Copyright © 2020 Andrew St Germain. All rights reserved.
//

import SwiftUI
import PartialSheet
import UIKit


struct ContentView: View {
    var sortType = ["Recommended", "Rating", "Distance", "Most Reviewed"]
    @ObservedObject var locationProvider : LocationProvider
    
    @State private var selectedSort = 0
    @State var term: String = ""
    @State var location: String = ""
    @State private var radius: Double = 0
    @State private var showPopover: Bool = false
    @State private var showFilterPopover: Bool = false
    @State private var modalPresented: Bool = false
    @State private var longer: Bool = false
    @State private var P1 = false
    @State private var P2 = false
    @State private var P3 = false
    @State private var P4 = false
    @State private var searchAlert = false
    @State private var eateryName = ""
    @State private var eateryLatitude: Double = 0.0
    @State private var eateryLongitude: Double = 0.0
    @State private var eateryNumber:URL!
    @State private var eateryImage = ""
    @State private var eateryYPURL:URL!
    @State private var eateryAddress1 = ""
    @State private var eateryAddress2 = ""
    @State private var eateryAddress3 = ""
    @State private var eateryCity = ""
    @State private var eateryState = ""
    @State private var eateryZip = ""
    
    let alert1 = Alert(title: Text("There were no results"))
    
    init() {
        locationProvider = LocationProvider()
        do {try locationProvider.start()}
        catch {
            print("No location access.")
            locationProvider.requestAuthorization()
        }
        
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                Text("")
                HStack {
                    VStack {
                        HStack{
                            Image(systemName: "magnifyingglass.circle").foregroundColor(.gray)
                            TextField("What do you feel like eating?", text: $term){
                                var priceString = ""
                                if(self.P1){
                                    priceString.append("1")
                                }
                                if(self.P2){
                                    if(priceString == ""){
                                        priceString.append("2")
                                    }
                                    else{
                                        priceString.append(",2")
                                    }
                                }
                                if(self.P3){
                                    if(priceString == ""){
                                        priceString.append("3")
                                    }
                                    else{
                                        priceString.append(",3")
                                    }
                                }
                                if(self.P4){
                                    if(priceString == ""){
                                        priceString.append("4")
                                    }
                                    else{
                                        priceString.append(",4")
                                    }
                                }
                                APIReq.getResult(term: self.term, latitude: (self.locationProvider.location?.coordinate.latitude)!,
                                                 longitude: (self.locationProvider.location?.coordinate.longitude)!, radius: self.radius, price: priceString) { result in
                                    //print(result.keys)
                                    let JSON = result
                                    //print(JSON)
                                    if let imageUrl = JSON["image_url"]{
                                        self.eateryImage = imageUrl as! String
                                    }
                                    if let businessName = JSON["name"]{
                                        self.eateryName = businessName as! String
                                        self.showPopover = true
                                    }
                                    else{
                                        self.searchAlert = true
                                    }
                                    if let coordinates = JSON["coordinates"] as? NSDictionary {
                                        self.eateryLatitude = coordinates["latitude"] as! Double
                                        self.eateryLongitude = coordinates["longitude"] as! Double
                                    }
                                    if let locate = JSON["location"] as? NSDictionary {
                                        self.eateryAddress1 = locate["address1"] as! String
                                        self.eateryCity = locate["city"] as! String
                                        self.eateryState = locate["state"] as! String
                                        self.eateryZip = locate["zip_code"] as! String
                                    }
                                    if let phoneNumber = JSON["phone"]{
                                        let pn = phoneNumber as! String
                                        let trimmedNumber = pn.replacingOccurrences(of: "+", with: "")
                                        let tel = "tel://"
                                        let formattedString = tel + trimmedNumber
                                        let url: URL = URL(string: formattedString)!
                                        self.eateryNumber = url
                                    }
                                    if let ypURL = JSON["url"]{
                                        let yp = ypURL as! String
                                        let url: URL = URL(string: yp)!
                                        self.eateryYPURL = url
                                    }
                                }
                            }
                                
                        }
                        .padding(10)
                        .font(Font.system(size: 15, weight: .medium, design: .serif))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                        .popover(isPresented: self.$showPopover, arrowEdge: .bottom) {
                            NavigationView {
                                VStack{
                                    ImageView(withURL: self.eateryImage)
                                    Text(self.eateryName)
                                    Button(action: {
                                        APIReq.openMapForPlace(tlatitude: self.eateryLatitude, tlongitude: self.eateryLongitude, pName: self.eateryName, a1: self.eateryAddress1, city: self.eateryCity, state: self.eateryState, zip: self.eateryZip)
                                    }){
                                        Text("Directions")
                                    }
                                    Button(action: {
                                        UIApplication.shared.open(self.eateryYPURL)
                                    }){
                                        Text("Go to Yelp")
                                    }
                                }
                                .navigationBarTitle(Text("Result"), displayMode: .inline)
                                .navigationBarItems(leading:
                                    Button(action: {
                                        self.showPopover = false
                                    }) {
                                        Group {
                                            Text("New Search")
                                        }.background(Color.white)
                                    },
                                                    trailing:
                                    Button(action: {
                                        UIApplication.shared.open(self.eateryNumber)
                                    }) {
                                        Group {
                                            Text("Call")
                                        } .background(Color.white)
                                    }
                                )
                            }
                        }
                    }.alert(isPresented: self.$searchAlert) {
                        self.alert1
                    }
                }
                
                HStack{
                    GeometryReader { geometry in
                        HStack{
                        Button(action: {self.P1.toggle()}) {
                            Text("$")
                                .foregroundColor(self.P1 ? .white : .black)
                        }
                            .accentColor(.black)
                            .padding(10)
                            .frame(width: geometry.size.width/4, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                            .background(RoundedRectangle(cornerRadius: 5.0)
                            .fill(self.P1 ? Color.blue : Color.white))
                        Button(action: {self.P2.toggle()}) {
                            Text("$$")
                                .foregroundColor(self.P2 ? .white : .black)
                        }   .accentColor(.black)
                            .padding(10)
                            .frame(width: geometry.size.width/4, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                            .background(RoundedRectangle(cornerRadius: 5.0)
                            .fill(self.P2 ? Color.blue : Color.white))
                        Button(action: {self.P3.toggle()}) {
                            Text("$$$")
                                .foregroundColor(self.P3 ? .white : .black)
                        }   .accentColor(.black)
                            .padding(10)
                            .frame(width: geometry.size.width/4, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                            .background(RoundedRectangle(cornerRadius: 5.0)
                            .fill(self.P3 ? Color.blue : Color.white))
                        Button(action: {self.P4.toggle()}) {
                            Text("$$$$")
                                .foregroundColor(self.P4 ? .white : .black)
                        }   .accentColor(.black)
                            .padding(10)
                            .frame(width: geometry.size.width/4, height: 50)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1))
                            .background(RoundedRectangle(cornerRadius: 5.0)
                            .fill(self.P4 ? Color.blue : Color.white))
                        }
                    }
                }
                if((Int(radius)) == 0){
                    Text("Search radius: None")
                }
                else{
                   Text("Search radius: \(Int(radius))")
                }
                //Consider adding buttons for search radius 1/5/10/25
                Slider(value: self.$radius, in: 0...25, step: 1)
                Spacer()
                HStack {
                    
                    Button("Filters") {
                        self.showFilterPopover = true
                    }
                        
                        
                    .accentColor(.white)
                    .padding()
                    .background(Color.gray)
                    .popover(isPresented: self.$showFilterPopover, arrowEdge: .bottom) {
                        NavigationView {
                            Text("Names")
                                .navigationBarTitle(Text("Filters"), displayMode: .inline)
                                .navigationBarItems(leading:
                                    Button(action: {
                                        self.showFilterPopover = false
                                    }) {
                                        Group {
                                            Text("Cancel")
                                        }.background(Color.white)
                                    },
                                                    trailing:
                                    Button(action: {
                                        print("tapped")
                                    }) {
                                        Group {
                                            Text("Reset")
                                        } .background(Color.white)
                                    }
                            )
                            
                            
                        }
                    }
                    
                    Button(action: {
                        self.modalPresented = true
                    }, label: {
                        Text("Sort")
                    })
                        .padding()
                        .accentColor(.white)
                        .background(Color.gray)
                    
                }
            }
            .padding()
            .navigationBarTitle("EatNow")
        }
        .partialSheet(presented: $modalPresented) {
            VStack {
                Group {
                    Text("Settings Panel")
                        .font(.subheadline)
                    Toggle(isOn: self.$longer) {
                        Text("Advanced")
                    }
                    HStack{
                        Text("Sort Type")
                        
                        Picker(selection: self.$selectedSort, label: Text("Sort")) {
                            ForEach(0 ..< self.sortType.count) {
                                Text(self.sortType[$0])
                                
                            }
                            
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                    }
                }
                .frame(height: 50)
                if self.longer {
                    VStack {
                        Text("More settings here...")
                    }
                    .frame(height: 200)
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
