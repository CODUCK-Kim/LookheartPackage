//
//  File.swift
//  
//
//  Created by KHJ on 10/28/24.
//

import Foundation
import SocketIO

public class SocketIOManager: NSObject {
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    typealias EventListener = NormalCallback
    
    public override init() {}
    
    func connect(
        url: String,
        endPoint: String,
        options: SocketIOClientConfiguration,
        eventListeners: [(String, EventListener)]
    ) {
        let manager = SocketManager(socketURL: URL(string: url)!, config: options)
        socket = manager.socket(forNamespace: endPoint)
        
        guard let socket = socket else {
            print("Socket init Error")
            return
        }
        
        // 이벤트 리스너 설정
        for (event, listener) in eventListeners {
            socket.on(event, callback: listener)
        }
        
        socket.connect()
    }
    
    func disconnect() {
        if checkSocketInitialization() {
            print("Socket Disconnected")
            socket?.disconnect()
            socket?.removeAllHandlers()
        }
    }
    
    
    /// JSON 객체
    func sendData(event: String, data: [String: Any]) {
        if checkSocketInitialization() {
            socket?.emit(event, data)
        }
    }
    
    
    func sendData(event: String, data: String) {
        if checkSocketInitialization() {
            socket?.emit(event, data)
        }
    }
    
    private func checkSocketInitialization() -> Bool {
        return socket?.status == .connected
    }
}
