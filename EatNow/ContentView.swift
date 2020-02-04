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
    
    @State private var selectedSort = 0
    @State var term: String = ""
    @State var location: String = ""
    @State private var showPopover: Bool = false
    @State private var modalPresented: Bool = false
    @State private var longer: Bool = false
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                Text("""
               Some information text! Here about the whole app and what it does.
               """)
                
                HStack {
                    TextField("Search", text: $term)
                        .border(Color.black)
                    TextField("Location", text: $location)
                        .border(Color.black)
                    Button("Test"){
                        APIReq.getResult(term: self.term, location: self.location) { result in
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
                Spacer()
                HStack {
                    Button("Filters") {
                        self.showPopover = true
                        self.modalPresented = true
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