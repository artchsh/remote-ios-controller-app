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
            .fill(isPressed ? Color.white : color.opacity(0.7))
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .overlay(
                Text(label)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isPressed ? color : .white)
            )
            .frame(width: 70, height: 70)
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2), value: isPressed)
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
