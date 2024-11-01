//
//  MapView.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import SwiftUI
import MapKit


struct MapView: View {
    @Binding var selectedLocation: Location?
    @State private var isBottomSheetPresented = true
    
    var body: some View {
      
        ZStack {
            Map(coordinateRegion: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: selectedLocation?.latitude ?? 0, longitude: selectedLocation?.longitude ?? 0),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )), showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: [selectedLocation].compactMap { $0 }) { location in
                MapPin(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), tint: .blue)
            }
            .ignoresSafeArea(edges: .all)
                 // Add a "Done" button
                 Button(action: {
                     isBottomSheetPresented = false
                     selectedLocation = nil
                 }) {
                     Text("Done")
                         .padding()
                 }
                 .frame(maxWidth: .infinity, alignment: .topTrailing)
             }
    }
}
