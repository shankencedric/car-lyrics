import Foundation
import WidgetKit

@objc(AppGroupModule)
class AppGroupModule: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { return false }

  @objc(setLyricsData:artist:previousLine:currentLine:nextLine:followingLine:artworkUrl:platform:progress:)
  func setLyricsData(
    _ title: String,
    artist: String,
    previousLine: String,
    currentLine: String,
    nextLine: String,
    followingLine: String,
    artworkUrl: String,
    platform: String,
    progress: Double
  ) {
    let defaults = UserDefaults(suiteName: "group.com.shankencedric.livelyrics")
    defaults?.set(title, forKey: "currentTitle")
    defaults?.set(artist, forKey: "currentArtist")
    defaults?.set(previousLine, forKey: "previousLyric")
    defaults?.set(currentLine, forKey: "currentLyric")
    defaults?.set(nextLine, forKey: "nextLyric")
    defaults?.set(followingLine, forKey: "followingLyric")
    defaults?.set(artworkUrl, forKey: "currentArtworkUrl")
    defaults?.set(platform, forKey: "widgetPlatform")
    defaults?.set(progress, forKey: "progress")
    defaults?.synchronize()

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}
