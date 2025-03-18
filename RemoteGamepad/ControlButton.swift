//
//  ControlButton.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/18/25.
//

import SwiftUI

struct ControlButton: View {
    let label: String
    let buttonName: String
    @ObservedObject var websocketManager: WebSocketManager
    @State private var isPressed = false
    
    var body: some View {
        Capsule()
            .fill(isPressed ? Color.white : Color.black.opacity(0.5))
            .frame(width: 80, height: 40)
            .overlay(
                Capsule()
                    .stroke(Color.gray, lineWidth: 2)
            )
            .overlay(
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isPressed ? Color.black : Color.white)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                        websocketManager.sendButtonCommand(
                            button: buttonName,
                            action: "press"
                        )
                    }
                    .onEnded { _ in
                        isPressed = false
                        websocketManager.sendButtonCommand(
                            button: buttonName,
                            action: "release"
                        )
                    }
            )
    }
}
