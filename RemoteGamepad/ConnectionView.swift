//
//  ConnectionView.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/17/25.
//

import SwiftUI

struct ConnectionView: View {
    @ObservedObject var websocketManager: WebSocketManager
    @State private var showingQuickConnect = false
    @State private var tempServerIP = ""
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                if websocketManager.isConnected {
                    websocketManager.disconnect()
                } else {
                    websocketManager.connect()
                }
            }) {
                HStack {
                    Image(systemName: websocketManager.isConnected ? "wifi" : "wifi.slash")
                        .font(.system(size: 18, weight: .semibold))
                    Text(websocketManager.isConnected ? "Disconnect" : "Connect")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(websocketManager.isConnected ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                )
            }
            
            Button(action: {
                showingQuickConnect = true
                tempServerIP = websocketManager.serverIP
            }) {
                HStack {
                    Image(systemName: "network")
                        .font(.system(size: 16))
                    Text("Quick IP")
                        .font(.system(size: 14))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.7))
                )
            }
        }
        .alert("Quick Connect", isPresented: $showingQuickConnect) {
            TextField("Server IP", text: $tempServerIP)
                .keyboardType(.decimalPad)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button("Cancel", role: .cancel) {}
            Button("Connect") {
                websocketManager.serverIP = tempServerIP
                websocketManager.connect()
            }
        } message: {
            Text("Enter the IP address of your gamepad server")
        }
    }
}
