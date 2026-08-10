import Foundation
import WidgetKit

@objc(AppGroupModule)
class AppGroupModule: NSObject {
  @objc static func requiresMainQueueSetup() -> Bool { return false }

  @objc(setLyricsData:artist:currentLine:artworkUrl:)
  func setLyricsData(_ title: String, artist: String, currentLine: String, artworkUrl: String) {
    let defaults = UserDefaults(suiteName: "group.com.shankencedric.carlyrics")
    defaults?.set(title, forKey: "currentTitle")
    defaults?.set(artist, forKey: "currentArtist")
    defaults?.set(currentLine, forKey: "currentLyric")
    defaults?.set(artworkUrl, forKey: "currentArtworkUrl")
    defaults?.synchronize()

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}