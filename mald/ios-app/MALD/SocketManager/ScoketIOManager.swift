//
//  ScoketIOManager.swift
//  MALD
//
//  Created by Ishaan
//

import Foundation
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var manager:SocketManager?

 
    
    override init() {
        super.init()
        manager = SocketManager(socketURL: NSURL(string: "http://136.52.104.32:8000")! as URL, config: [
          .log(true),
          .compress,
          .reconnects(true),
          .forceWebsockets(false)
      ])
    }
    
    
    func establishConnection() {
        let socket = manager?.defaultSocket

        socket?.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            socket?.emit("message", ["id": socket?.sid ?? "", "status": "", "prestataireId":  ""])
        }
        socket?.on(clientEvent: .error) {data, ack in
            print("socket error")
        }
        
        socket?.connect()
    }
    
    
    func closeConnection() {
        let socket = manager?.defaultSocket

        socket?.disconnect()
    }
    
    func getWarningMessages(completionHandler: @escaping (_ messageInfo: Any) -> Void) {
        let socket = manager?.defaultSocket

        socket?.on("custom event"){data, ack in
            print("Got new warning message \(data)")
            completionHandler(data)
        }
    }
}
