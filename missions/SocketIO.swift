//
//  Socket.swift
//  missions
//
//  Created by Umar Qattan on 9/8/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation
import SocketIO

class SocketIO {
    
    private var manager: SocketManager?
    var socket: SocketIOClient?
    private var resetAck: SocketAckEmitter?
    
    func setupSocket(ipAddress: String) {
        self.manager = SocketManager(
            socketURL: URL(string: ipAddress)!,
            config: [.compress, .log(true)]
        )
        
        self.socket = self.manager?.defaultSocket
    }
    
    func connect() {
        self.socket?.connect()
    }
    
    func disconnect() {
        self.socket?.disconnect()
    }
    
    func addHandlers(_ completion: @escaping (_ data: [Any]) -> Void) {
        guard let socket = self.socket else { return }
        
        socket.on("message") { data, ack in
            completion(data)
        }
    }
    
    func removeAllHandlers() {
        self.socket?.removeAllHandlers()
    }
    
}
