//
//  ContentView.swift
//  EatNow
//
//  Created by Andrew St Germain on 1/24/20.
//  Copyright © 2020 Andrew St Germain. All rights reserved.
//

import SwiftUI
import PartialSheet


struct ContentView: View {
    var sortType = ["Recommended", "Rating", "Distance", "Most Reviewed"]
    @ObservedObject var locationProvider : LocationProvider
    
    @State private var selectedSort = 0
    @State var term: String = ""
    @State var location: String = ""
    @State private var radius: Double = 0
    @State private var showPopover: Bool = false
    @State private var modalPresented: Bool = false
    @State private var longer: Bool = false
    @State private var P1 = false
    @State private var P2 = false
    @State private var P3 = false
    @State private var P4 = false
    
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
                Text("""
               Some information text! Here about the whole app and what it does.
               """)
                
                
                HStack {
                    VStack {
                        TextField("What do you feel like eating?", text: $term)
                            .border(Color.black)
                        Button("Search"){
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
                                print(result.keys)
                                let JSON = result
                                if let total = JSON["total"] as? NSNumber {
                                    print(total)
                                }
                                if let region = JSON["region"] as? NSDictionary {
                                    print(region)
                                }
                                if let businesses = JSON["businesses"] as? NSArray {
                                    print(businesses)
                                }
                                
                                //let coords = JSON["coordinates"] as! NSDictionary
                                //let latitude = coords["latitude"]!
                                //let longitude = coords["longitude"]!
                                //print(coords)
                                //print(latitude)
                                //print(longitude)
                            }
                            
                            
                        }
                        .accentColor(.white)
                        .padding()
                        .background(Color.gray)
                    }
                }
                if((Int(radius)) == 0){
                    Text("Search radius: None")
                }
                else{
                   Text("Search radius: \(Int(radius))")
                }
                HStack{
                    Button(action: {self.P1.toggle()}) {
                        Text("$")
                            .foregroundColor(.white)
                    }   .padding(.all)
                        .background(RoundedRectangle(cornerRadius: 5.0)
                                    .fill(self.P1 ? Color.green : Color.blue))
                    Button(action: {self.P2.toggle()}) {
                        Text("$$")
                            .foregroundColor(.white)
                    }   .padding(.all)
                        .background(RoundedRectangle(cornerRadius: 5.0)
                                    .fill(self.P2 ? Color.green : Color.blue))
                    Button(action: {self.P3.toggle()}) {
                        Text("$$$")
                            .foregroundColor(.white)
                    }   .padding(.all)
                        .background(RoundedRectangle(cornerRadius: 5.0)
                                    .fill(self.P3 ? Color.green : Color.blue))
                    Button(action: {self.P4.toggle()}) {
                        Text("$$$$")
                            .foregroundColor(.white)
                    }   .padding(.all)
                        .background(RoundedRectangle(cornerRadius: 5.0)
                                    .fill(self.P4 ? Color.green : Color.blue))
                }
                
                Slider(value: self.$radius, in: 0...25, step: 1)
                Spacer()
                HStack {
                    
                    Button("Filters") {
                        self.showPopover = true
                    }
                        
                        
                    .accentColor(.white)
                    .padding()
                    .background(Color.gray)
                    .popover(isPresented: self.$showPopover, arrowEdge: .bottom) {
                        NavigationView {
                            Text("Names")
                                .navigationBarTitle(Text("Filters"), displayMode: .inline)
                                .navigationBarItems(leading:
                                    Button(action: {
                                        self.showPopover = false
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
