//
//  Location.swift
//  MALD
//
//  Created by Ishaan Chaturvedi 
//

import Foundation

struct Location: Identifiable, Codable {
    var name: String
    var latitude: Double
    var longitude: Double
    var id =  UUID()
}
