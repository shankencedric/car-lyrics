# Car Lyrics
An Expo React Native application delivering real-time synchronized music lyrics to iOS devices, Lock Screen Live Activities / Dynamic Island widgets, and Apple CarPlay displays.

## Environment Prerequisites
- macOS: Sonoma 14.5 or later
- Xcode: 16.1+
- Node.js: 18.x or later
- CocoaPods: 1.13.0+

## Quick Setup
1. Install dependencies:
```Bash
npm install
```
2. Configure Xcode local environment:
```Bash
echo "export NODE_BINARY=$(which node)" > ios/.xcode.env.local
echo "export REACT_NATIVE_PATH=$(pwd)/node_modules/react-native" >> ios/.xcode.env.local
```
3. Install CocoaPods:
```Bash
cd ios && pod install && cd ..
```
## Development & Testing
### Running in Simulator
```Bash
npx expo run:ios
````
### Enabling CarPlay Display
1. Boot the app in the iOS Simulator.
2. In the Mac menu bar, navigate to I/O $\rightarrow$ External Displays $\rightarrow$ CarPlay.
3. A secondary CarPlay window will launch. Click the app icon to test CarPlaySceneDelegate templates.

## CarPlay Entitlement Rules
Add `<key>com.apple.developer.carplay-audio</key>` to `ios/carlyrics/carlyrics.entitlements` when deploying with a **paid Apple Developer Account** to allow profile signing.
