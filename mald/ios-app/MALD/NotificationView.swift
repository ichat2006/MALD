//
//  NotificationView.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import SwiftUI

struct NotificationView: View {
        var body: some View {
                     GeometryReader { geometry in
                         UIKitViewControllerContainer()
                             .frame(width: geometry.size.width, height: geometry.size.height) // Adjust the frame as needed
                             }
                     .navigationTitle("WiFi Configuration")
                     .navigationBarTitleDisplayMode(.inline)
                      }
    
}
