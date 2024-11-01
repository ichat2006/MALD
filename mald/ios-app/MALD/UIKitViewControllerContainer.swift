//
//  UIKitViewControllerContainer.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import SwiftUI

struct UIKitViewControllerContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main",     // < your storyboard name here
                 bundle: nil)
           let viewController = storyboard.instantiateViewController(identifier:
                 "ViewController")      // < your controller storyboard id here

           return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the UIKit view controller here if needed
    }
}
