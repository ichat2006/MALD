//
//  UserDefaultsViewModel.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation

class UserDefaultsViewModel: ObservableObject {
    @Published var savedLocations: [Location] = []

    init() {
        // Load saved locations from UserDefaults on initialization
        if let data = UserDefaults.standard.data(forKey: "SavedLocations") {
            if let decoded = try? JSONDecoder().decode([Location].self, from: data) {
                savedLocations = decoded
            }
        }
    }

    func saveLocations() {
        if let encoded = try? JSONEncoder().encode(savedLocations) {
            UserDefaults.standard.set(encoded, forKey: "SavedLocations")
        }
    }

    func addLocation(location: Location) {
        savedLocations.append(location)
        saveLocations()
    }

    func deleteLocation(at index: Int) {
        savedLocations.remove(at: index)
        saveLocations()
    }
}
