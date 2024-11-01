//
//  SavedLocationView.swift
//  MALD
//
//  Created by Ishaan
//

import SwiftUI


import SwiftUI

struct SavedLocationView: View {
    @ObservedObject var viewModel = LocationViewModel()
    @State private var newLocationName = ""
    @State private var newLocationLatitude = ""
    @State private var newLocationLongitude = ""
    @State private var selectedLocation: Location?
    @ObservedObject var userDefaultsViewModel = UserDefaultsViewModel()
     var locationSelectionCallback: ((Location?) -> Void)? = nil
        

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Add a Location")) {
                    TextField("Location Name", text: $newLocationName)
                    TextField("Latitude", text: $newLocationLatitude)
                    TextField("Longitude", text: $newLocationLongitude)
                    Button("Save Location") {
                        if let latitude = Double(newLocationLatitude), let longitude = Double(newLocationLongitude) {
                            let newLocation = Location(name: newLocationName, latitude: latitude, longitude: longitude)
                            userDefaultsViewModel.addLocation(location: newLocation)
                            newLocationName = ""
                            newLocationLatitude = ""
                            newLocationLongitude = ""
                        }
                    }
                }

                Section(header: Text("Saved Locations")) {
                    
                    ForEach(userDefaultsViewModel.savedLocations) { location in
                        Button(action: {}) {
                            
                            HStack {
                                Text(location.name)
                                Spacer()
                                Button {
                                    if let handder = self.locationSelectionCallback {
                                        handder(location)
                                    }
                                    selectedLocation = location
                                } label: {
                                    Text("Navigate")
                                }
                                
                                Button {
                                    if let index = userDefaultsViewModel.savedLocations.firstIndex(where: { $0.id == location.id }) {
                                        userDefaultsViewModel.deleteLocation(at: index)
                                    }
                                } label: {
                                    Text("Delete")
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("My Locations")
        }
        .sheet(item: $selectedLocation) { location in
            MapView(selectedLocation: $selectedLocation)
                           .ignoresSafeArea(edges: .all)
        }
    }
}

struct SavedLocationView_Previews: PreviewProvider {
    static var previews: some View {
        SavedLocationView()
    }
}
