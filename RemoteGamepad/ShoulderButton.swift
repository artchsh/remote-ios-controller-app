//
//  ShoulderButton.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/18/25.
//

import SwiftUI

struct ShoulderButton: View {
    let label: String
    let buttonName: String
    @ObservedObject var websocketManager: WebSocketManager
    @State private var isPressed = false
    
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
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
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
