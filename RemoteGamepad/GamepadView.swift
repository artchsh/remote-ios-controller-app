import SwiftUI

struct GamepadView: View {
    @ObservedObject var websocketManager: WebSocketManager
    @State private var showingSettings = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.1, green: 0.1, blue: 0.1)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // Status Bar
                    HStack {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                        }
                        .frame(width: 150)
                        Spacer()

                        // Bottom Control Buttons
                        HStack(spacing: 20) {
                            ControlButton(systemImage: "rectangle.on.rectangle", buttonName: "back", websocketManager: websocketManager)
                            ControlButton(systemImage: "gamecontroller.fill", buttonName: "home", websocketManager: websocketManager)
                            ControlButton(systemImage: "line.3.horizontal", buttonName: "start", websocketManager: websocketManager)
                        }

                        Spacer()

                        // Connection Status
                        HStack {
                            Circle()
                                .fill(websocketManager.isConnected ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            Text(websocketManager.isConnected ? "Connected" : "Disconnected")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 150)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    HStack() {
                        HStack() {
                            ShoulderButton(label: "LT", buttonName: "lt", websocketManager: websocketManager)
                                .frame(width: 100, height: 100)

                            ShoulderButton(label: "LB", buttonName: "lb", websocketManager: websocketManager)
                                .frame(width: 70, height: 70, alignment: .bottom)
                                .offset(x: -10, y: 45)
                        }
                        
                        Spacer()

                        HStack() {
                            ShoulderButton(label: "RB", buttonName: "rb", websocketManager: websocketManager)
                                .frame(width: 70, height: 70, alignment: .bottom)
                                .offset(x: 10, y: 45)

                            ShoulderButton(label: "RT", buttonName: "rt", websocketManager: websocketManager)
                                .frame(width: 100, height: 100)
                        }
                    }

                    HStack() {
                        DPadView(websocketManager: websocketManager)
                            .frame(width: 150, height: 150)
                        
                        Spacer()

                        ZStack {
                            VStack(spacing: 45) {
                                ShoulderButton(label: "Y", buttonName: "y", websocketManager: websocketManager)
                                ShoulderButton(label: "A", buttonName: "a", websocketManager: websocketManager)
                            }

                            HStack(spacing: 45) {
                                ShoulderButton(label: "X", buttonName: "x", websocketManager: websocketManager)
                                ShoulderButton(label: "B", buttonName: "b", websocketManager: websocketManager)
                            }
                        }
                        .frame(width: 170, height: 170)
                        .offset(x:  20 )

                    }
                    .offset(y:10)
                    HStack(spacing: 100) {
                        
                        JoystickView(stickType: "left", websocketManager: websocketManager)
                        
                        JoystickView(stickType: "right", websocketManager: websocketManager)
                    }
                    .offset(y: -130)
                }
                .preferredColorScheme(.dark)
                .sheet(isPresented: $showingSettings) {
                    SettingsView(websocketManager: websocketManager)
                }
            }
        }
    }
}
