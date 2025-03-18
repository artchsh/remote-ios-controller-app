# Virtual Gamepad iOS Client

A mobile app for iPhone that connects to the Virtual Gamepad WebSocket Server, allowing you to use your iPhone as a gamepad controller for your Windows PC.

## Features

- Uses WebSockets to communicate with the server
- Works only in landscape mode for optimal gaming experience
- Configurable server connection (IP address and port)
- Supports all standard Xbox 360 controller inputs
- Vibration feedback support
- Custom UI controls designed for touchscreen use

## Requirements

- iOS 15.0 or later
- iPhone device (optimized for iPhone)
- [Virtual Gamepad WebSocket Server](https://github.com/artchsh/remote-ios-controller-server) running on a Windows PC

## Installation

### Option 1: Sideloading with AltStore

1. Install [AltStore](https://altstore.io/) on your computer and set it up with your device
2. Download the IPA file from the [Releases](../../releases) tab
3. Open the IPA file with AltStore to install it on your device

### Option 2: Sideloading with Sideloadly

1. Install [Sideloadly](https://sideloadly.io/) on your computer
2. Connect your iPhone to your computer
3. Download the IPA file from the [Releases](../../releases) tab
4. Drag and drop the IPA into Sideloadly and follow the installation instructions

## Usage

1. Make sure the [Virtual Gamepad WebSocket Server](https://github.com/artchsh/remote-ios-controller-server) is running on your Windows PC
2. Find your PC's local IP address in your network settings
3. Launch the app on your iPhone
4. Tap the settings icon and enter your PC's IP address (the default port is 8000)
5. Tap "Connect" to establish a connection
6. Use the on-screen controls to control your virtual gamepad

## Development

### Requirements

- Xcode 14.0 or later
- Swift 5.5 or later
- iOS 15.0+ deployment target

### Dependencies

- [Starscream](https://github.com/daltoniam/Starscream) - WebSocket client library for Swift

### Building the Project

1. Clone the repository
2. Open the `.xcodeproj` file in [Xcode](https://developer.apple.com/xcode/)
3. Install the dependencies using Swift Package Manager
4. Build and run the project on your device

## Related Projects

- **Server Component**: [https://github.com/artchsh/remote-ios-controller-server](https://github.com/artchsh/remote-ios-controller-server) - The Windows server component that this app connects to

## Android Support

There are currently no plans for Android support.

## Contributions

Contributions are welcome! Feel free to submit issues or pull requests to help improve the app.

## License

[MIT License](LICENSE)
