import SwiftUI

struct JoystickView: View {
    @State private var position = CGPoint.zero
    @State private var isDragging = false
    let stickType: String
    @ObservedObject var websocketManager: WebSocketManager
    
    private let maxDistance: CGFloat = 70
    private let innerCircleSize: CGFloat = 70
    private let outerCircleSize: CGFloat = 150
    
    var body: some View {
        ZStack {
            joystickBackground
            joystickThumb
            // Button offset based on stick type
            GamepadButton(
                label: stickType == "left" ? "LS" : "RS",
                buttonName: stickType == "right" ? "ls" : "rs",
                websocketManager: websocketManager
            )
            .offset(x: stickType == "left" ? (outerCircleSize / 2) : -(outerCircleSize / 2),
                    y: -outerCircleSize / 2 + -25) // Positioned on top side
        }
        .frame(width: outerCircleSize, height: outerCircleSize)
    }
    
    private var joystickBackground: some View {
        Circle()
            .fill(Color.black.opacity(0.5))
            .frame(width: outerCircleSize, height: outerCircleSize)
            .overlay(
                Circle().stroke(Color.white, lineWidth: 2)
            )
    }
    
    private var joystickThumb: some View {
        Circle()
            .fill(isDragging ? Color.white : Color.gray.opacity(0.8))
            .frame(width: innerCircleSize, height: innerCircleSize)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
            .offset(x: position.x, y: position.y)
            .gesture(dragGesture)
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                
                let translation = value.translation
                let distance = hypot(translation.width, translation.height)
                
                if distance > maxDistance {
                    let scale = maxDistance / distance
                    position = CGPoint(x: translation.width * scale, y: translation.height * scale)
                } else {
                    position = CGPoint(x: translation.width, y: translation.height)
                }
                
                let xValue = Int((position.x / maxDistance) * 32767)
                let yValue = Int((position.y / maxDistance) * 32767)
                websocketManager.sendJoystickCommand(stick: stickType, x: xValue, y: yValue)
            }
            .onEnded { _ in
                isDragging = false
                withAnimation(.spring(response: 0.3)) {
                    position = .zero
                }
                websocketManager.sendJoystickCommand(stick: stickType, x: 0, y: 0)
            }
    }
}
