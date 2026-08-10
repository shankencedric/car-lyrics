import Foundation
import ActivityKit

@objc(LiveActivityModule)
class LiveActivityModule: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { return false }

  @objc(startActivity:artist:currentLine:)
  func startActivity(_ title: String, artist: String, currentLine: String) {
    if #available(iOS 16.1, *) {
      let attributes = CarLyricsWidgetAttributes(name: "Car Lyrics")
      let initialState = CarLyricsWidgetAttributes.ContentState(
        title: title,
        artist: artist,
        lyric: currentLine
      )
      do {
        _ = try Activity<CarLyricsWidgetAttributes>.request(
          attributes: attributes,
          contentState: initialState,
          pushType: nil
        )
      } catch {
        print("Failed to start Live Activity: \(error)")
      }
    }
  }

  @objc(updateActivity:artist:currentLine:)
  func updateActivity(_ title: String, artist: String, currentLine: String) {
    if #available(iOS 16.1, *) {
      let updatedState = CarLyricsWidgetAttributes.ContentState(
        title: title,
        artist: artist,
        lyric: currentLine
      )
      Task {
        for activity in Activity<CarLyricsWidgetAttributes>.activities {
          await activity.update(using: updatedState)
        }
      }
    }
  }

  @objc func endActivity() {
    if #available(iOS 16.1, *) {
      Task {
        for activity in Activity<CarLyricsWidgetAttributes>.activities {
          await activity.end(dismissalPolicy: .immediate)
        }
      }
    }
  }
}
