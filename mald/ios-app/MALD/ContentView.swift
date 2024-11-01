//
//  ContentView.swift
//  MALD
//
//  Created by Ishaan
//

import SwiftUI
import AVFoundation


struct ContentView: View {
    @EnvironmentObject var appState: AppState
    private let client = Client()
    @State private var showPresenter = !UserDefaults.standard.bool(forKey: "presenterScreenShown")




    var body: some View {
        if !appState.isAppLaunched {
              if showPresenter {
                PresenterScreen()
                    .environmentObject(appState) // Pass appState here
                    .onTapGesture {
                        // Dismiss presenter screen when tapped outside the content
                        dismissPresenter()
                    }
              } else {
                  LaunchView()
                      .onAppear {
                          DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                              withAnimation {
                                  appState.isAppLaunched = true
                              }
                          }
                      }
              }

        } else {
            TabView {
                NavigationView {
                    DeviceSetupView()
                        .navigationBarTitle("Home")
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
                
                    NotificationView()
                        .navigationBarTitle("")
                    
                .tabItem {
                    Label("Navigation", systemImage: "mappin.circle.fill")
                }
                
                NavigationView {
                    SettingView()
                        .navigationBarTitle("Settings")
                    
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
    }
    
    func dismissPresenter() {
        UserDefaults.standard.set(true, forKey: "presenterScreenShown")
        }
}



struct DeviceSetupView : View {
    @State private var isToggled = false
    @StateObject private var viewModel = ContentViewModel()
      private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.isDeviceOn ? "faxmachine.fill" : "faxmachine")
                .font(.system(size: 60))
                .foregroundColor(viewModel.isDeviceOn  ? .yellow : .gray)
            Text("Device Status: \(viewModel.isDeviceOn  ? "On" : "Off")")
                .font(.headline)
                .alert(item: self.$viewModel.response) { response in
                    Alert(title: Text("Msg"),
                          message: Text(response.msg),
                          dismissButton: .default(Text("Ok"), action: {}))
                }
            if self.viewModel.isLoading {
                ProgressView("Updating...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                Toggle("Switch \(viewModel.isDeviceOn  ? "Off" : "On") the Device", isOn: $viewModel.isDeviceOn )
                    .padding()
                    .onChange(of: viewModel.isDeviceOn) { newValue in
                        print("CUrrent device Status \(viewModel.isDeviceOn)")
                        print("NEw Value: \(newValue)")
                        updateDeviceStatus()
                    }
            }
            Text("Obstacle Messages")
            VStack {
                Button(action: {
                    speakText(text: self.viewModel.obstacleMessage)
                }) {
                    Text("Speak")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                if !(self.viewModel.obstacleMessage.isEmpty) {
                    Text(self.viewModel.obstacleMessage)
                        .onAppear {
                                    speakText(text: self.viewModel.obstacleMessage)
                                }
                } else {
                    Text("No Obstacle route is clear")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.all)
        .task {
            Task {
                // DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                
                //while true {
              try await  self.viewModel.deviceStatus()
                //  while true {
                //   try await Task.sleep(nanoseconds: 2_000_000_000)
                
                self.viewModel.setUpSicket {
                    
                    //  }
                    
                    //  }
                    
                    
                    
                    //  }
                    // }
                    // }
                    
                    // }
                }
            }
        }
    }
    
    func updateDeviceStatus()  {
        // Simulate an async operation, e.g., sending a network request
        Task {
            await viewModel.startDevice()
        } 
    }
    
    func speakText(text: String) {
        
           let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
           speechUtterance.rate = 0.5 // Adjust speech rate as needed
           synthesizer.speak(speechUtterance)
       }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
