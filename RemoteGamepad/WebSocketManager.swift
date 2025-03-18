import Foundation
import Combine
import SwiftUI
import Starscream

class WebSocketManager: ObservableObject, WebSocketDelegate {
    // MARK: - Properties
    private var socket: WebSocket?
    private var connectionTimeoutCancellable: AnyCancellable?
    private var pingCancellable: AnyCancellable?
    private var reconnectCancellable: AnyCancellable?
    
    private var serverAddress: String { "ws://\(serverIP):\(port)/ws" }
    
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var connectionError: String?
    @Published var serverIP: String
    @Published var port: Int
    
    init(serverIP: String, port: Int = 8000) {
        self.serverIP = serverIP
        self.port = port
    }
    
    deinit { disconnect() }
    
    // MARK: - Connection Management
    func connect() {
        guard !isConnecting else { return }
        guard let url = URL(string: serverAddress) else {
            connectionError = "Invalid server URL"
            return
        }
        
        print("Connecting to WebSocket at: \(url.absoluteString)")
        isConnecting = true
        connectionError = nil
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
        
        startConnectionTimeoutTimer()
        startPingTimer()
    }
    
    func disconnect() {
        socket?.disconnect()
        isConnected = false
        isConnecting = false
        stopPingTimer()
        stopReconnectTimer()
        stopConnectionTimeoutTimer()
    }
    
    private func reconnect() {
        disconnect()
        connect()
    }
    
    // MARK: - Timer Management with Combine
    private func startConnectionTimeoutTimer() {
        stopConnectionTimeoutTimer()
        connectionTimeoutCancellable = Just(())
            .delay(for: .seconds(5.0), scheduler: RunLoop.main)
            .sink { [weak self] in
                guard let self = self, self.isConnecting, !self.isConnected else { return }
                self.connectionError = "Connection timeout. Please check the server address and try again."
                self.isConnecting = false
                self.disconnect()
            }
    }
    
    private func stopConnectionTimeoutTimer() {
        connectionTimeoutCancellable?.cancel()
        connectionTimeoutCancellable = nil
    }
    
    private func startPingTimer() {
        stopPingTimer()
        pingCancellable = Timer.publish(every: 15.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.sendPing() }
    }
    
    private func stopPingTimer() {
        pingCancellable?.cancel()
        pingCancellable = nil
    }
    
    private func startReconnectTimer() {
        stopReconnectTimer()
        reconnectCancellable = Just(())
            .delay(for: .seconds(5.0), scheduler: RunLoop.main)
            .sink { [weak self] in self?.reconnect() }
    }
    
    private func stopReconnectTimer() {
        reconnectCancellable?.cancel()
        reconnectCancellable = nil
    }
    
    private func sendPing() {
        socket?.write(ping: Data()) {}
    }
    
    // MARK: - WebSocketDelegate Implementation
    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch event {
            case .connected(let headers):
                print("WebSocket connected: \(headers)")
                self.isConnected = true
                self.isConnecting = false
                self.stopConnectionTimeoutTimer()
            case .disconnected(let reason, let code):
                print("WebSocket disconnected: \(reason) (code: \(code))")
                self.isConnected = false
                self.isConnecting = false
                self.connectionError = "Disconnected: \(reason)"
                self.startReconnectTimer()
            case .text(let text):
                print("Received text: \(text)")
                self.handleIncomingMessage(text)
            case .binary(let data):
                print("Received binary: \(data)")
            case .ping(_):
                print("Received ping")
            case .pong(_):
                print("Received pong")
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                self.startReconnectTimer()
            case .cancelled:
                print("WebSocket cancelled")
                self.isConnected = false
                self.isConnecting = false
                self.startReconnectTimer()
            case .error(let error):
                print("WebSocket error: \(String(describing: error))")
                self.isConnected = false
                self.isConnecting = false
                self.connectionError = "Error: \(error?.localizedDescription ?? "Unknown error")"
                self.startReconnectTimer()
            case .peerClosed:
                print("WebSocket peer closed connection")
                self.isConnected = false
                self.isConnecting = false
                self.startReconnectTimer()
            }
        }
    }
    
    // MARK: - Message Handling
    private func handleIncomingMessage(_ message: String) {
        guard let data = message.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        
        if let vibration = jsonObject["vibration"] as? [String: Any],
           let leftMotor = vibration["leftMotor"] as? Int,
           let rightMotor = vibration["rightMotor"] as? Int {
            triggerVibration(leftIntensity: leftMotor, rightIntensity: rightMotor)
        }
    }
    
    // MARK: - Vibration Support
    private func triggerVibration(leftIntensity: Int, rightIntensity: Int) {
        if leftIntensity > 0 || rightIntensity > 0 {
            let intensity = max(leftIntensity, rightIntensity)
            let generator = UIImpactFeedbackGenerator(style: intensity > 128 ? .heavy : .medium)
            generator.impactOccurred()
        }
    }
    
    // MARK: - Controller Commands
    
    /// Send joystick position to the server
    /// - Parameters:
    ///   - stick: Stick identifier ("left" or "right")
    ///   - x: X-axis value (-32768 to 32767)
    ///   - y: Y-axis value (-32768 to 32767)
    func sendJoystickCommand(stick: String, x: Int, y: Int) {
        guard isConnected else { return }
        
        let command: [String: Any] = [
            "type": "joystick",
            "stick": stick,
            "x": x,
            "y": y
        ]
        
        sendCommand(command)
    }
    
    /// Send button press/release event to the server
    /// - Parameters:
    ///   - button: Button identifier (a, b, x, y, lb, rb, lt, rt, etc.)
    ///   - action: Action ("press" or "release")
    func sendButtonCommand(button: String, action: String) {
        guard isConnected else { return }
        
        let command: [String: Any] = [
            "type": "button",
            "button": button,
            "action": action
        ]
        
        sendCommand(command)
    }
    
    /// Send trigger analog value to the server
    /// - Parameters:
    ///   - trigger: Trigger identifier ("lt" or "rt")
    ///   - value: Analog value (0-255)
    func sendTriggerCommand(trigger: String, value: Int) {
        guard isConnected else { return }
        
        let command: [String: Any] = [
            "type": "trigger",
            "trigger": trigger,
            "value": value
        ]
        
        sendCommand(command)
    }
    
    /// Helper method to send any command as JSON
    private func sendCommand(_ command: [String: Any]) {
        guard isConnected, let socket = socket else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: command)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.write(string: jsonString)
            }
        } catch {
            print("Error serializing command: \(error)")
        }
    }
}
