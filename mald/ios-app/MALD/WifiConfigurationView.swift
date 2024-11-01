//
//  WifiConfigurationView.swift
//  MALD
//
//  Created by Ishaan
//
import SwiftUI
import Network

struct WifiConfigurationView: View {
    @State private var currentSSID: String = "Not available"
    @StateObject private var viewModel = WifiConfigurationViewModel()
    @State private var newSSID: String = ""
    @State private var wifiName: String = ""
    @State private var password: String = ""
    @State private var isAddingWifi = false
    @State private var isSwitchingWifi = false
    @State private var connecting = false

    private var connectionStates: [Bool] {
           Array(repeating: false, count: viewModel.configuredNetworks.count)
       }
    
    var body: some View {
            Form {
                Section(header: Text("Current WiFi Connected to")) {
                    Text(self.viewModel.currentSSID.isEmpty ? "Not Available" : self.viewModel.currentSSID)
                }
                
                Button(action: {
                    fetchCurrentWifiSSID()
                }) {
                    Text("Refresh Current WiFi")
                }

                Section(header:
                            HStack {
                                               Text("List Configured Networks")
                                               Spacer()
                                               Button(action: {
                                                   fetchConfiguredNetworks()
                                               }) {
                                                   Image(systemName: "arrow.clockwise")
                                               }
                                           }
                ) {
                    if self.viewModel.configuredNetworks.isEmpty {
                        EmptyListView()
                    } else {
                        List(0..<viewModel.configuredNetworks.count, id: \.self) { index in
                            let network = viewModel.configuredNetworks[index]
                            ConnectionRow(
                                network: network,
                                connectionState: $viewModel.connectionStates[index],
                                isLoading: viewModel.loadingRow == index
                            ) {
                                connectToNetwork(at: index)
                            }
                        }
                    }
                }
                
                Section(header: Text("Add WiFi Network")) {
                    TextField("Enter SSID", text: $newSSID)
                    TextField("Wifi Name", text: $wifiName)
                    SecureField("Wifi Password", text: $password)

                    Button(action: {
                        addWifiNetwork()
                    }) {
                        Text("Add WiFi Network")
                    }
                }
              
            }
            .navigationTitle("WiFi Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchCurrentWifiSSID()
            }
    }
    

    
    private func connectToNetwork(at index: Int) {
        // Ensure only one row is loading at a time
        if viewModel.loadingRow == nil {
            viewModel.loadingRow = index
            Task {
                await viewModel.connectToNetwork(at: index)
            }
        }
    }

    private func fetchCurrentWifiSSID() {
        Task {
            await viewModel.fetchCurrentWifiSSID()
        }
    }

    private func fetchConfiguredNetworks() {
       
        Task {
            await viewModel.fetchConfiguredNetworks()
        }
    }

    private func addWifiNetwork() {
        // Implement adding a WiFi network
        Task {
            await viewModel.addWifiNetwork(newSSID: newSSID,wifiName: wifiName,password: password)
        }
    }
}

struct WifiConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        WifiConfigurationView()
    }
}


struct ConnectionRow: View {
    let network: String
    @Binding var connectionState: Bool
    let isLoading: Bool
    let connectAction: () -> Void
    
    var body: some View {
        HStack {
            Text(network)
            Spacer()
            Button(action: {
                    connectStateAction()
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 30, height: 30)
                        .background(Color.blue)
                        .cornerRadius(15)
                } else {
                    Text(connectionState ?  "Connected" : "Connect")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue)
                        .cornerRadius(5)
                }
            }
        }
    }

    private func connectStateAction() {
        connectionState = false // Set to false while loading
        connectAction()
    }
}


struct EmptyListView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "wifi.slash")
                .resizable()
                               .aspectRatio(contentMode: .fit)
                               .frame(width: 44, height: 44,alignment: .center)
                               .foregroundColor(.gray)
            Text("No configured networks")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
        }
    }
}
