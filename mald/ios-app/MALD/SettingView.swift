//
//  SettingView.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import SwiftUI
import SafariServices
import WebKit

struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}


struct SettingView: View {
    @State private var isPresentingSafariView = false
    @State private var isPresentingWifiConfigurationView = false
  
    let settings = [
        Item(title: "Device Settings", subitems: [
            SubItem(title: "Locations",navigationType: .location),
            SubItem(title: "Wifi Configuration",navigationType: .wifiConfiguration),
            SubItem(title: "Reboot Device", navigationType: .rebootDevice)
        ]),
        Item(title: "About Us", subitems: [
            SubItem(title: "Info",navigationType: .info),
            SubItem(title: "Contact Us",navigationType: .contactUs),
            SubItem(title: "Terms and Condition Policy",navigationType: .termAndCondition),
        ])
    ]
    
    var body: some View {
          NavigationView {
              List {
                  ForEach(settings) { setting in
                      Section(header: Text(setting.title)) {
                          ForEach(setting.subitems) { subitem in
                              ItemView(subitem: subitem, isPresentingSafariView: $isPresentingSafariView)
                          }
                      }
                  }
              }
              .sheet(isPresented: $isPresentingWifiConfigurationView) {
                  WifiConfigurationView()
              }
              .listStyle(GroupedListStyle())
          }
      }
}


struct Item: Identifiable {
    let id = UUID()
    let title: String
    let subitems: [SubItem]
}

struct SubItem: Identifiable {
    let id = UUID()
    let title: String
    let navigationType: NavigationType
}

enum NavigationType {
    case location
    case wifiConfiguration
    case contactUs
    case termAndCondition
    case rebootDevice
    case info
}



struct ItemView: View {
    var subitem: SubItem
    @Binding var isPresentingSafariView: Bool
    @StateObject private var viewModel = WifiConfigurationViewModel()
    @Environment(\.openURL) var openURL

    var body: some View {
        switch subitem.navigationType {
        case .wifiConfiguration:
            NavigationLink(destination: WifiConfigurationView()) {
                Text(subitem.title)
            }
            .navigationBarTitle("")
        case .location:
            NavigationLink(destination: SavedLocationView()) {
                Text(subitem.title)
            }
            .navigationBarTitle("")
        case .info:
            NavigationLink(destination: PresenterScreen(hideBottomButton: true)) {
                Text(subitem.title)
            }
            .navigationBarTitle("")
        case .contactUs:
            NavigationLink(destination: ContactUsView()) {
                Text(subitem.title)
            }
            .navigationBarTitle("")
        case .rebootDevice:
            Button(action: {
                Task {
                    await  viewModel.rebootDevice()
                }
            }) {
                Text(subitem.title)
            }
        case .termAndCondition:
            Button(action: {
                openURL(URL(string: "https://www.privacypolicyonline.com/live.php?token=qaJE62DNajwHnJ3agObqPMUepwlHLhM3")!)

            }) {
                Text(subitem.title)
            }
        default:
            Text(subitem.title)
        }
    }
}
