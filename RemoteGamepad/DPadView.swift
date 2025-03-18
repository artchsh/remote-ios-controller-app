//
//  DPadView.swift
//  RemoteGamepad
//
//  Created by artchsh on 3/18/25.
//

import SwiftUI

struct DPadView: View {
    @ObservedObject var websocketManager: WebSocketManager
    @State private var activeDirection: String?
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.5))
                .frame(width: 150, height: 150)
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                )
            
            // D-pad directions
            VStack(spacing: 0) {
                dpadButton("up")
                HStack(spacing: 0) {
                    dpadButton("left")
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 50, height: 50)
                    dpadButton("right")
                }
                dpadButton("down")
            }
        }
    }
    
    private func dpadButton(_ direction: String) -> some View {
        let isActive = activeDirection == direction
        
        return Rectangle()
            .fill(isActive ? Color.white : Color.gray.opacity(0))
            .frame(width: 50, height: 50)
            .overlay(
                Image(systemName: arrowName(for: direction))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isActive ? Color.black : Color.white)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        activeDirection = direction
                        websocketManager.sendButtonCommand(
                            button: direction,
                            action: "press"
                        )
                    }
                    .onEnded { _ in
                        activeDirection = nil
                        websocketManager.sendButtonCommand(
                            button: direction,
                            action: "release"
                        )
                    }
            )
    }
    
    private func arrowName(for direction: String) -> String {
        switch direction {
        case "up": return "chevron.up"
        case "down": return "chevron.down"
        case "left": return "chevron.left"
        case "right": return "chevron.right"
        default: return "circle"
        }
    }
}
