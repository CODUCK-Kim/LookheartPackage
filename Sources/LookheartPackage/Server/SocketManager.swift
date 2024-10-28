//
//  File.swift
//  
//
//  Created by KHJ on 10/28/24.
//

import Foundation
import SocketIO

public class SocketIOManager {
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    public typealias EventListener = NormalCallback
    
    public init() { }
    
    public func connect(
        url: String,
        endPoint: EndPoint,
        options: SocketIOClientConfiguration,
        eventListeners: [(String, EventListener)]
    ) {
        let manager = SocketManager(socketURL: URL(string: url)!, config: options)
        socket = manager.socket(forNamespace: endPoint.rawValue)
        
        guard let socket = socket else {
            print("Socket init Error")
            return
        }
        
        for (event, listener) in eventListeners {
            socket.on(event, callback: listener)
        }
        
        socket.connect()
    }
    
    public func disconnect() {
        if checkSocketInitialization() {
            print("Socket Disconnected")
            socket?.disconnect()
            socket?.removeAllHandlers()
        }
    }
    
    
    /// JSON 객체
    public func sendData(event: String, data: [String: Any]) {
        if checkSocketInitialization() {
            socket?.emit(event, data)
        }
    }
    
    
    public func sendData(event: String, data: String) {
        if checkSocketInitialization() {
            socket?.emit(event, data)
        }
    }
    
    private func checkSocketInitialization() -> Bool {
        return socket?.status == .connected
    }
}
