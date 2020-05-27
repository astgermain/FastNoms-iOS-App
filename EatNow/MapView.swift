//
//  MapView.swift
//  EatNow
//
//  Created by Andrew St Germain on 5/26/20.
//  Copyright © 2020 Andrew St Germain. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI



struct MapView: UIViewRepresentable {
    
    @Binding var centerCoordinate: CLLocationCoordinate2D
    var annotations: [MKPointAnnotation]
    
    @State private var locationProvider = LocationProvider()
    @State private var oneTime: Bool = false
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        do {try locationProvider.start()
            //print("Location access.")
        }
        catch {
            //print("No location access.")
            locationProvider.requestAuthorization()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
        let span = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
            if(self.centerCoordinate.latitude != mapView.userLocation.coordinate.latitude && self.centerCoordinate.longitude != mapView.userLocation.coordinate.longitude && self.oneTime != true){
            self.centerCoordinate = mapView.userLocation.coordinate
            self.oneTime = true
        }
        
        })
        
        //print(self.locationProvider.authorizationStatus?.name)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        
        /*
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to the 2012 Summer Olympics."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.5, longitude: -118.13)
        view.addAnnotation(annotation)
         */
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        view.removeAnnotations(annotations)
        if(annotations.capacity > 0){
            view.addAnnotation(annotations[annotations.endIndex - 1])
        }
        view.setRegion(region, animated: true)
        
        view.showsUserLocation = true
        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        }
    }
}

extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to the 2012 Summer Olympics."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.5, longitude: -118.13)
        return annotation
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate), annotations: [MKPointAnnotation.example])
    }
}
