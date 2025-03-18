//
//  ContentView.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var websocketManager = WebSocketManager(serverIP: "192.168.1.39") // Default IP
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                GamepadView(websocketManager: websocketManager)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .preferredColorScheme(.dark)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
