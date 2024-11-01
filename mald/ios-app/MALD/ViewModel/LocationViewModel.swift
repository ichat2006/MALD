//
//  LocationViewModel.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import MapKit

class LocationViewModel: ObservableObject {
    @Published var savedLocations: [Location] = []

    func addLocation(name: String, latitude: Double, longitude: Double) {
        let newLocation = Location(name: name, latitude: latitude, longitude: longitude)
        savedLocations.append(newLocation)
    }

    func navigateToLocation(location: Location) {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: MKPlacemark(placemark: placemark))

        mapItem.name = location.name
        mapItem.openInMaps(launchOptions: nil)
    }
}
