//
//  WifiConfigurationViewModel.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import Network
import SwiftUI

@MainActor
class WifiConfigurationViewModel: ObservableObject {
    @Published var currentSSID: String = "Not available"
    @Published var configuredNetworks: [String] = []
    private let client = Client()
    @Published  var isLoading: Bool = false
    var connection: NWConnection!
    @Published var hasError: Bool = false
    @Published var response: Response? // <- Set your error from your api here
    @Published private(set) var errorMessage: String = ""
    
    @Published var connectionStates: [Bool] = Array(repeating: false, count: 3) // Initialize with false for each network
    @Published var loadingRow: Int? = nil // Track the row being loaded


    
    var fetchCurrentWifiRequest: URLRequest = {
        let urlString = "\(BASE_URL)/current_wifi"
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }()
    
    var addWifiRequest: URLRequest = {
        let urlString = "\(BASE_URL)/\(UrlPath.addWifi)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }()
    
    var switchWifiNetworkRequest: URLRequest = {
        let urlString = "\(BASE_URL)/\(UrlPath.switchWifiNetwork)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }()
    
    var listConfiguredNetworkRequest: URLRequest = {
        let urlString = "\(BASE_URL)/\(UrlPath.listConfiguredNetwork)"
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }()
    
    var rebootDeviceRequest: URLRequest = {
        let urlString = "\(BASE_URL)/\(UrlPath.rebootDevice)"
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }()
    
    
    func fetchCurrentWifiSSID() async {
            isLoading = true
            do {
                let response = try await client.fetchString(with: fetchCurrentWifiRequest)
                isLoading = false
                print("Response: \(response)")
                self.currentSSID = response
            } catch {
                isLoading = false
                if let error = error as? ApiError {
                    errorMessage = "\(error.customDescription)"
                    hasError = true
                }
              
            }
    }

    func fetchConfiguredNetworks() async {
        isLoading = true
        do {
            var response = try await client.fetchString(with: listConfiguredNetworkRequest)
            isLoading = false
            print("Response: \(response)")
            response = response.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "")
            configuredNetworks = response.components(separatedBy: ",").filter({!$0.isEmpty})
            connectionStates = Array(repeating: false, count: configuredNetworks.count)
            
        } catch {
            isLoading = false
            if let error = error as? ApiError {
                errorMessage = "\(error.customDescription)"
                hasError = true
            }
            
            
        }
    }

    
    func rebootDevice() async {
        isLoading = true
        do {
            var response = try await client.fetchString(with: rebootDeviceRequest)
            isLoading = false
            print("Response: \(response)")
            response = response.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "")
            
        } catch {
            isLoading = false
            if let error = error as? ApiError {
                errorMessage = "\(error.customDescription)"
                hasError = true
            }
            
            
        }
    }
    
    func addWifiNetwork(newSSID: String,wifiName: String,password: String) async {
        
        let requestData: [String: Any] = [
            "SSID": newSSID,
            "wifi_name": wifiName,
            "password": password
        ]

        isLoading = true
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)

            var request = addWifiRequest
            request.httpBody = jsonData
            let response = try await client.fetchString(with: request)
            print("Response: \(response)")
        } catch {
            isLoading = false
            if let error = error as? ApiError {
                errorMessage = "\(error.customDescription)"
                hasError = true
            }
          
        }
    }

    func connectToNetwork(at index: Int) async {
        
        // Stop loading the previous row (if any)
          if let previousLoadingRow = loadingRow {
              connectionStates[previousLoadingRow] = false
          }
        let requestData: [String: Any] = [
            "switch_to_wifi": self.configuredNetworks[index],
        ]

        // Set the loading row
        loadingRow = index
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestData)

            var request = switchWifiNetworkRequest
            request.httpBody = jsonData
            let response = try await client.fetchString(with: request)
            print("Response: \(response)")
            if response != "Both current and new wifi connections are same" {
                connectionStates[index] = true
            } else {
               
            }
            loadingRow = nil
        } catch {
            if let error = error as? ApiError {
                errorMessage = "\(error.customDescription)"
                hasError = true
                connectionStates[index] = false
                loadingRow = nil
            }
          
        }

//        Task {
//            do {
//                // Replace this with your actual networking logic and response handling
//                // For example, you might call an asynchronous network request here
//                try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulate a 2-second delay
//
//                // If successful, update the connection state and clear the loading row
//                connectionStates[index] = true
//                loadingRow = nil
//            } catch {
//                // Handle any errors
//                loadingRow = nil
//            }
//        }
    }


}
