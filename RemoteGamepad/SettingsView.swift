//
//  SettingsView.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/17/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var websocketManager: WebSocketManager
    @State private var tempServerIP: String = ""
    @State private var tempPort: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    init(websocketManager: WebSocketManager) {
        self.websocketManager = websocketManager
        _tempServerIP = State(initialValue: websocketManager.serverIP)
        _tempPort = State(initialValue: String(websocketManager.port))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Configuration")) {
                    TextField("Server IP", text: $tempServerIP)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    TextField("Port", text: $tempPort)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Connection")) {
                    Button(action: {
                        saveSettings()
                        if websocketManager.isConnected {
                            websocketManager.disconnect()
                        } else {
                            websocketManager.connect()
                        }
                    }) {
                        HStack {
                            Text(websocketManager.isConnected ? "Disconnect" : "Connect")
                            Spacer()
                            Image(systemName: websocketManager.isConnected ? "wifi" : "wifi.slash")
                        }
                    }
                    .foregroundColor(websocketManager.isConnected ? .red : .blue)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        if websocketManager.isConnecting {
                            Text("Connecting...")
                                .foregroundColor(.orange)
                        } else if websocketManager.isConnected {
                            Text("Connected")
                                .foregroundColor(.green)
                        } else {
                            Text("Disconnected")
                                .foregroundColor(.red)
                        }
                    }
                    
                    if let error = websocketManager.connectionError {
                        HStack {
                            Text("Error")
                            Spacer()
                            Text(error)
                                .foregroundColor(.red)
                                .font(.callout)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(
                trailing: Button("Save") {
                    saveSettings()
                }
            )
        }
    }
    
    private func saveSettings() {
        if let port = Int(tempPort), port > 0 && port <= 65535 {
            websocketManager.port = port
        }
        
        websocketManager.serverIP = tempServerIP
    }
}
