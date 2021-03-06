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
import MapKit


struct ContentView: View {
    var sortType = ["Any", "1mi", "5mi", "10m", "15mi", "25mi"]
    @ObservedObject var locationProvider : LocationProvider
    
    @State private var selectedSort = 0
    @State var term: String = ""
    @State var location: String = ""
    @State private var radius: Double = 0
    @State private var showPopover: Bool = false
    @State private var showFilterPopover: Bool = false
    @State private var modalPresented: Bool = true
    @State private var resultsPresented: Bool = false
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
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var eateryCoordinate = CLLocationCoordinate2D()
    @State private var locations = [MKPointAnnotation]()
    @State private var currentLocation = CLLocationCoordinate2D()
    
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
        
        
        VStack {
            /*
             Text("Name of my app")
             .font(Font.system(size: 32, weight: .heavy))
             */
            ZStack(alignment: .bottomTrailing) {
                MapView(centerCoordinate: self.$eateryCoordinate, annotations: self.locations)
                    .edgesIgnoringSafeArea(.top)
                    .edgesIgnoringSafeArea(.bottom)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray).padding()
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
                                if(self.selectedSort == 0){
                                    self.radius = 0
                                }
                                else if(self.selectedSort == 1){
                                    self.radius = 1
                                }
                                else if(self.selectedSort == 2){
                                    self.radius = 5
                                }
                                else if(self.selectedSort == 3){
                                    self.radius = 10
                                }
                                else if(self.selectedSort == 4){
                                    self.radius = 15
                                }
                                else if(self.selectedSort == 5){
                                    self.radius = 25
                                }
                                //Pass in categories to choose from food, bar, etc
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
                                                        self.eateryCoordinate = CLLocationCoordinate2D(latitude: self.eateryLatitude, longitude: self.eateryLongitude)
                                                        let newLocation = MKPointAnnotation()
                                                        newLocation.coordinate = self.eateryCoordinate
                                                        self.locations.append(newLocation)
                                                    }
                                                    
                                                    if let locate = JSON["location"] as? NSDictionary {
                                                        if let a1 = locate["address1"]as? String {
                                                            self.eateryAddress1 = a1
                                                        }
                                                        if let c = locate["city"] as? String {
                                                            self.eateryCity = c
                                                        }
                                                        if let s = locate["state"] as? String {
                                                            self.eateryState = s
                                                        }
                                                        if let z = locate["zip_code"] as? String {
                                                            self.eateryZip = z
                                                        }
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
                                                    self.modalPresented = false
                                                    self.resultsPresented.toggle()
                                }
                                
                            }
                            .keyboardType(.webSearch)
                            .font(Font.system(size: 15, weight: .medium, design: .rounded))
                            /*
                             .popover(isPresented: self.$showPopover, arrowEdge: .bottom) {
                             NavigationView {
                             VStack(alignment: .center) {
                             MapView(centerCoordinate: self.$eateryCoordinate, annotations: self.locations)
                             .edgesIgnoringSafeArea(.all)
                             
                             HStack {
                             Text(self.eateryName)
                             .font(Font.system(size: 32, weight: .heavy))
                             }
                             .padding()
                             HStack {
                             Text(self.eateryAddress1)
                             .font(Font.system(size: 16, weight: .light))
                             .foregroundColor(.black)
                             }
                             
                             HStack {
                             Text(self.eateryCity)
                             .font(Font.system(size: 16, weight: .light))
                             .foregroundColor(.black)
                             Text(self.eateryState)
                             .font(Font.system(size: 16, weight: .light))
                             .foregroundColor(.black)
                             Text(self.eateryZip)
                             .font(Font.system(size: 16, weight: .light))
                             .foregroundColor(.black)
                             }
                             
                             HStack {
                             Button(action: {
                             APIReq.openMapForPlace(tlatitude: self.eateryLatitude, tlongitude: self.eateryLongitude, pName: self.eateryName, a1: self.eateryAddress1, city: self.eateryCity, state: self.eateryState, zip: self.eateryZip)
                             }){
                             Text("Directions")
                             .padding()
                             .foregroundColor(.white)
                             .frame(maxWidth: .infinity)
                             }
                             .accentColor(.blue)
                             .background(RoundedRectangle(cornerRadius: 10)
                             .fill(Color.blue))
                             }
                             .padding()
                             HStack {
                             Button(action: {
                             UIApplication.shared.open(self.eateryYPURL)
                             }){
                             Text("Go to Yelp")
                             .padding()
                             .foregroundColor(.white)
                             .frame(maxWidth: .infinity)
                             }
                             .accentColor(.blue)
                             .background(RoundedRectangle(cornerRadius: 10)
                             .fill(Color.blue))
                             }
                             .padding()
                             
                             
                             
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
                             */
                            Button(action: {self.modalPresented.toggle()}){
                                Image(systemName: "line.horizontal.3.decrease.circle").foregroundColor(.gray).padding()
                            }
                            
                        }
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1), alignment: .topLeading)
                        .foregroundColor(.black)
                        .accentColor(.gray)
                        .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white))
                        .padding()
                        , alignment: .topLeading)
            }.partialSheet(presented: $modalPresented, enableCover: false) {
                VStack {
                    Group {
                        Text("Filters")
                            .font(.subheadline)
                        HStack {
                            GeometryReader { geometry in
                                Button(action: {}) {
                                    Text("")
                                        .foregroundColor(self.P1 ? .white : .gray)
                                        .frame(width: geometry.size.width, height: 35)
                                }
                                .accentColor(.gray)
                                .background(RoundedRectangle(cornerRadius: 25)
                                .fill(Color.gray))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                
                                Button(action: {self.P1.toggle()}) {
                                    Text("$")
                                        .foregroundColor(self.P1 ? .white : .black)
                                        .frame(width: geometry.size.width/4 - 1, height: 35)
                                        .font(Font.system(size: 12, design: .monospaced))
                                }
                                .accentColor(.gray)
                                .background(RoundedRectangle(cornerRadius: 0.0)
                                .fill(self.P1 ? Color.blue : Color.white))
                                .cornerRadius(radius: 25, corners: [.topLeft, .bottomLeft])
                                
                                Button(action: {self.P2.toggle()}) {
                                    Text("$$")
                                        .foregroundColor(self.P2 ? .white : .black)
                                        .frame(width: geometry.size.width/4 - 1, height: 35)
                                        .font(Font.system(size: 12, design: .monospaced))
                                }
                                .accentColor(.gray)
                                .background(RoundedRectangle(cornerRadius: 0.0)
                                .fill(self.P2 ? Color.blue : Color.white))
                                .padding(.horizontal, geometry.size.width/4)
                                
                                Button(action: {self.P3.toggle()}) {
                                    Text("$$$")
                                        .foregroundColor(self.P3 ? .white : .black)
                                        .frame(width: geometry.size.width/4 - 1, height: 35)
                                        .font(Font.system(size: 12, design: .monospaced))
                                }
                                .accentColor(.gray)
                                .background(RoundedRectangle(cornerRadius: 0.0)
                                .fill(self.P3 ? Color.blue : Color.white))
                                    
                                .padding(.horizontal, geometry.size.width/2)
                                
                                Button(action: {self.P4.toggle()}) {
                                    Text("$$$$")
                                        .foregroundColor(self.P4 ? .white : .black)
                                        .frame(width: geometry.size.width/4, height: 35)
                                        .font(Font.system(size: 12, design: .monospaced))
                                    
                                }
                                .accentColor(.gray)
                                .background(RoundedRectangle(cornerRadius: 0.0)
                                .fill(self.P4 ? Color.blue : Color.white))
                                .cornerRadius(radius: 25, corners: [.topRight, .bottomRight])
                                .padding(.horizontal, geometry.size.width/4 + geometry.size.width/2)
                                
                            }
                        }
                        
                        HStack{
                            
                            Text("Distance")
                            Picker(selection: self.$selectedSort, label: Text("Sort")) {
                                ForEach(0 ..< self.sortType.count) {
                                    Text(self.sortType[$0])
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        Button(action: {self.longer.toggle()}) {
                            if self.longer{
                                Text("Hide Advanced Filters")
                            }
                            else{
                                Text("Advanced Filters")
                            }
                            
                        }
                    }
                    .frame(height: 50).padding(.horizontal)
                    if self.longer {
                        VStack {
                            Text("More settings here...")
                        }
                        .frame(height: 200)
                    }
                }
            }.partialSheet(presented: $resultsPresented, enableCover: false) {
                    VStack(alignment: .center) {
                        HStack {
                            Text(self.eateryName)
                                .font(Font.system(size: 32, weight: .heavy))
                        }
                        .padding()
                        HStack {
                            Text(self.eateryAddress1)
                                .font(Font.system(size: 16, weight: .light))
                                .foregroundColor(.black)
                        }
                        
                        HStack {
                            Text(self.eateryCity)
                                .font(Font.system(size: 16, weight: .light))
                                .foregroundColor(.black)
                            Text(self.eateryState)
                                .font(Font.system(size: 16, weight: .light))
                                .foregroundColor(.black)
                            Text(self.eateryZip)
                                .font(Font.system(size: 16, weight: .light))
                                .foregroundColor(.black)
                        }
                        
                        HStack {
                            Button(action: {
                                APIReq.openMapForPlace(tlatitude: self.eateryLatitude, tlongitude: self.eateryLongitude, pName: self.eateryName, a1: self.eateryAddress1, city: self.eateryCity, state: self.eateryState, zip: self.eateryZip)
                            }){
                                Text("Directions")
                                    .padding()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .accentColor(.blue)
                            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue))
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        HStack{
                            Button(action: {
                                UIApplication.shared.open(self.eateryNumber)
                            }) {
                                Text("Call")
                                    .padding()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                            }
                            .accentColor(.blue)
                            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue))
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        HStack {
                            Button(action: {
                                UIApplication.shared.open(self.eateryYPURL)
                            }){
                                Text("Go to Yelp")
                                    .padding()
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                            }
                            .accentColor(.blue)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        
                        
                        
                        
                    }.padding(.horizontal)
                    //CALL BUTTON
                    /*
                        
                    */
                    
                
                
                
            }
            
        }
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        let sl = CAShapeLayer()
        
        func path(in rect: CGRect) -> Path {
            
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
        
        
        
    }
}


extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
    
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
        
        return overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(content, lineWidth: width))
    }
}

