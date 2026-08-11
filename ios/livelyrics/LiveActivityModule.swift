import Foundation
import ActivityKit

// 1. Local Attributes Definition (Matches Widget extension 1:1 for ActivityKit bridge)
public struct LiveLyricsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var artist: String
        var lyric: String
    }
    var name: String
}

// 2. React Native Bridge Module
@objc(LiveActivityModule)
class LiveActivityModule: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { return false }

  @objc(startActivity:artist:currentLine:)
  func startActivity(_ title: String, artist: String, currentLine: String) {
    if #available(iOS 16.1, *) {
      let attributes = LiveLyricsWidgetAttributes(name: "Live Lyrics")
      let initialState = LiveLyricsWidgetAttributes.ContentState(
        title: title,
        artist: artist,
        lyric: currentLine
      )
      do {
        _ = try Activity<LiveLyricsWidgetAttributes>.request(
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
      let updatedState = LiveLyricsWidgetAttributes.ContentState(
        title: title,
        artist: artist,
        lyric: currentLine
      )
      Task {
        for activity in Activity<LiveLyricsWidgetAttributes>.activities {
          await activity.update(using: updatedState)
        }
      }
    }
  }

  @objc func endActivity() {
    if #available(iOS 16.1, *) {
      Task {
        for activity in Activity<LiveLyricsWidgetAttributes>.activities {
          await activity.end(dismissalPolicy: .immediate)
        }
      }
    }
  }
}
