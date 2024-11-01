//
//  PresenterScreen.swift
//  MALD
//
//  Created by Ishaan
//

import SwiftUI

struct PresenterScreen: View {
    @EnvironmentObject var appState: AppState // Add this line
    @State var hideBottomButton: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                Image(uiImage: UIImage(named: "Device")!)
                    .frame(width: 200,height: 200)
                    .foregroundColor(.blue)
                    .padding(.top,hideBottomButton ? 24.0 : 150)
                Text("The device in this picture is designed to help people with Ultra Low Vision to navigate from place to place independently without needing much physical assistance from others. The devices is controlled by a smart phone app (MALD) which communicates with device (using smart phone). The device identifies any objects or other safety hazard or obstruction in the path way of the user.  The smart phone app uses map to provide user turn-by-turn directions from source to destination and does not store any data outside smart phone.")
                    .padding(.leading,20.0)
                    .padding(.trailing, 20.0)
                    .multilineTextAlignment(.center)
                if !hideBottomButton {
                    Button(action: {
                        dismissPresenter()
                    }) {
                        Text("Got it, Let's Begin!")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 24.0)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func dismissPresenter() {
        appState.isAppLaunched = true
        UserDefaults.standard.set(true, forKey: "presenterScreenShown")
    }
}

