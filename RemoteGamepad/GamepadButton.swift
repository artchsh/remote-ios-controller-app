//
//  GamepadButton.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/17/25.
//

import SwiftUI

struct GamepadButton: View {
    let label: String
    let buttonName: String
    let color: Color
    @ObservedObject var websocketManager: WebSocketManager
    @State private var isPressed = false
    
    init(label: String, buttonName: String, color: Color = .gray, websocketManager: WebSocketManager) {
        self.label = label
        self.buttonName = buttonName
        self.color = color
        self.websocketManager = websocketManager
    }
    
    var body: some View {
        Circle()
            .fill(isPressed ? Color.white : Color.black.opacity(0.5))
            .overlay(
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
            )
            .overlay(
                Text(label)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(isPressed ? Color.black : Color.white)
            )
            .frame(width: 70, height: 70)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if (!isPressed) {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            isPressed = true
                            websocketManager.sendButtonCommand(
                                button: buttonName,
                                action: "press"
                            )
                        }
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
