//
//  LaunchView.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color(hex: "#A6E4FA")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: -30) {
                Image("MALD")
                    .font(.system(size: 200))
                    .foregroundColor(.blue)
                Text("MALD")
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
