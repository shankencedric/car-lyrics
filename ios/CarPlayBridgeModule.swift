import Foundation
import CarPlay
import React

@objc(CarPlayBridgeModule)
class CarPlayBridgeModule: NSObject {
    
    @objc static function requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc(updateCarPlayLyrics:artist:currentLine:isPlaying:resolver:rejecter:)
    func updateCarPlayLyrics(
        title: String,
        artist: String,
        currentLine: String,
        isPlaying: Bool,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        DispatchQueue.main.async {
            CarPlaySceneDelegate.shared?.updateCarPlayDisplay(
                title: title,
                artist: artist,
                currentLine: currentLine,
                isPlaying: isPlaying
            )
            resolve(true)
        }
    }
}