import Foundation
import ActivityKit
import React

@objc(LyricsActivityModule)
class LyricsActivityModule: NSObject {
    private var currentActivity: Any? = nil

    @objc static function requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc(startActivity:artistName:currentLine:nextLine:resolver:rejecter:)
    func startActivity(
        trackTitle: String,
        artistName: String,
        currentLine: String,
        nextLine: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 16.1, *) else {
            reject("UNSUPPORTED", "ActivityKit requires iOS 16.1 or higher", nil)
            return
        }

        // End existing activity before starting a new one
        endCurrentActivitySync()

        let attributes = LyricsActivityAttributes(
            trackTitle: trackTitle,
            artistName: artistName
        )
        
        let initialState = LyricsActivityAttributes.ContentState(
            currentLine: currentLine,
            nextLine: nextLine.isEmpty ? nil : nextLine,
            isPlaying: true
        )

        do {
            let activity = try Activity<LyricsActivityAttributes>.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            self.currentActivity = activity
            resolve(activity.id)
        } catch {
            reject("ACTIVITY_ERROR", "Failed to start Live Activity: \(error.localizedDescription)", error)
        }
    }

    @objc(updateActivity:nextLine:resolver:rejecter:)
    func updateActivity(
        currentLine: String,
        nextLine: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        guard #available(iOS 16.1, *) else { return }
        guard let activity = currentActivity as? Activity<LyricsActivityAttributes> else {
            resolve(false)
            return
        }

        let updatedState = LyricsActivityAttributes.ContentState(
            currentLine: currentLine,
            nextLine: nextLine.isEmpty ? nil : nextLine,
            isPlaying: true
        )

        Task {
            await activity.update(using: updatedState)
            resolve(true)
        }
    }

    @objc(endActivity:rejecter:)
    func endActivity(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        endCurrentActivitySync()
        resolve(true)
    }

    private func endCurrentActivitySync() {
        guard #available(iOS 16.1, *) else { return }
        if let activity = currentActivity as? Activity<LyricsActivityAttributes> {
            Task {
                await activity.end(dismissalPolicy: .immediate)
            }
            self.currentActivity = nil
        }
    }
}