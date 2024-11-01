//
//  ContentViewModel.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import SocketIO
import Network
import MobileCoreServices
import UniformTypeIdentifiers
import SocketIO
import AVFoundation


struct Message: LocalizedError, Identifiable {
    
    let msg: String
    var id: String { localizedDescription }
}

@MainActor
final class ContentViewModel: ObservableObject {
    private let client = Client()
    var manager:SocketManager? = SocketManager(socketURL: NSURL(string: "http://136.52.104.32:8000")! as URL, config: [
        .log(true),
        .compress,
        .reconnects(true),
        .forceWebsockets(false)
    ])
    

    @Published private(set) var errorMessage: String = ""
    @Published  var message: String = ""
    @Published  var isLoading: Bool = false
    var connection: NWConnection!
    @Published var hasError: Bool = false
    @Published  var isDeviceOn: Bool = false
    @Published var response: Response? // <- Set your error from your api here
    private let synthesizer = AVSpeechSynthesizer()

    @Published  var obstacleMessage: String = "No obstacle for now" {
        didSet {
            let speechUtterance = AVSpeechUtterance(string: obstacleMessage)
         speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-AU")
            speechUtterance.rate = 0.5 // Adjust speech rate as needed
            synthesizer.speak(speechUtterance)
        }
    }



    var request: URLRequest = {
        let urlString = "\(BASE_URL)/start"
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }()
    
    var statusRequest: URLRequest = {
        let urlString = "\(BASE_URL)/status"
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }()
    
    var stopRequest: URLRequest = {
        let urlString = "\(BASE_URL)/stop"
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }()
    
    
    
    func connectToTcp() {
        let PORT: NWEndpoint.Port = 8000
        let ipAddress: NWEndpoint.Host = "136.52.104.32"
        let queue = DispatchQueue(label: "TCP Client Queue")
        
        let tcp = NWProtocolTCP.Options()
        tcp.noDelay = true
        let params = NWParameters(tls: nil, tcp: tcp)
        connection = NWConnection(to: NWEndpoint.hostPort(host: ipAddress, port: PORT), using: params)
        
        connection.stateUpdateHandler = { [weak self] (newState) in
            guard let self = self else { return }
            
            switch newState {
            case .waiting(let error):
                print("Error: \(error)")
            case .ready:
                print("Socket State: Ready")
                UserDefaults.standard.set(true, forKey: "isConnected")
                Task {
                    await self.sendMSG()
                }
                Task {
                    await self.receive()
                }
            default:
                UserDefaults.standard.set(false, forKey: "isConnected")
            }
        }
        
        connection.start(queue: queue)
    }
    
    
        func sendMSG() async {
        print("send data")
        let message1 = "hello world"
        let content: Data = message1.data(using: .utf8)!
        connection.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
            if (NWError == nil) {
                print("Data was sent to TCP destination ")
                
            } else {
                print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!)")
            }
        })))
    }
    
    
        func receive() async {
        connection.receiveMessage { (data, context, isComplete, error) in
            if (isComplete) {
//                print("Receive is complete, count bytes: \(data!.count)")
                if (data != nil) {
//                    print(data!.byteToHex())
                    print("Data:\(data)")
                    let message = String(data: data!, encoding: .utf8)
                    print("Message:\(message)")

                } else {
                    print("Data == nil")
                }
            }
        }
    }
    
    func setUpSicket(handler:@escaping () -> Void) {
        self.connected(status: "",handler: handler)

    }
    


    func connected(status: String,handler: @escaping () -> Void) {

    
        print("socket try to connecting.....")


        manager?.defaultSocket.on(clientEvent: .connect) {data, ack in
        print("socket connected")
            self.manager?.defaultSocket.emit("message", ["id": self.manager?.defaultSocket.sid ?? "", "status": status, "prestataireId":  ""])
    }
        manager?.defaultSocket.on(clientEvent: .error) {data, ack in
        print("socket error")
    }
        manager?.defaultSocket.on("custom event"){data, ack in
        print("socket newPrestation \(data)")
        debugPrint("#### Debug print\(data)")
                handler()
            
            if let messageData = data.first as? [String: Any],let messsage = messageData["msgs"] as? String {
            self.obstacleMessage = messsage
        }
    }


        manager?.defaultSocket.connect()
    }
    

    func deviceStatus() async {
        isLoading = true
        do {
            let response = try await client.fetchString(with: statusRequest)
            
            if let jsonData = response.data(using: .utf8) {
                do {
                    // Parse the JSON data
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let status = jsonObject["status"] as? Bool {
                        if status {
                            // The "status" is true
                            print("Status is true")
                            isDeviceOn = true
                        } else {
                            // The "status" is false
                            print("Status is false")
                            isDeviceOn = false
                        }
                    } else {
                        isDeviceOn = false
                        print("Failed to extract the 'status' field from JSON.")
                    }
                } catch {
                    isDeviceOn = false
                    print("Error parsing JSON: \(error)")
                }
            } else {
                isDeviceOn = false
                print("Failed to convert the string to data.")
            }
            isLoading = false

        } catch {
            isLoading = false
            if let error = error as? ApiError {
                errorMessage = "\(error.customDescription)"
                hasError = true
                isDeviceOn = false
            }
          
        }
    }
    
    func startDevice() async {
        isLoading = true
        do {
            print("current deviceSttua: \(isDeviceOn)")
            let response = try await client.fetchString(with: isDeviceOn ? request : stopRequest)
            isLoading = false
            isDeviceOn = isDeviceOn ? true : false
            message = response
            print("Response: \(response)")
        } catch {
            isDeviceOn = false
            isLoading = false
            if let error = error as? ApiError {
                errorMessage = "\(error.customDescription)"
                hasError = true
                isDeviceOn = false
            }
          
        }
    }
}


struct Response: Codable, LocalizedError,Identifiable {
    let msg: String
    let status: Bool
    var id: String { localizedDescription }

}

struct CurrentWifiResponse: Codable, LocalizedError,Identifiable {
    let msg: String
    var id: String { localizedDescription }
}
