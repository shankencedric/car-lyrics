import Foundation
import CarPlay
import UIKit

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    
    static var shared: CarPlaySceneDelegate?
    private var interfaceController: CPInterfaceController?
    
    // Now Playing Template managed by CarPlay OS
    private let nowPlayingTemplate = CPNowPlayingTemplate.shared
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        CarPlaySceneDelegate.shared = self
        self.interfaceController = interfaceController
        
        // Set NowPlaying as the root template on CarPlay screen
        interfaceController.setRootTemplate(nowPlayingTemplate, animated: true, completion: nil)
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnectInterfaceController interfaceController: CPInterfaceController
    ) {
        CarPlaySceneDelegate.shared = nil
        self.interfaceController = nil
    }
    
    /**
     * Updates CarPlay display with current track metadata and live lyrics line.
     */
    func updateCarPlayDisplay(title: String, artist: String, currentLine: String, isPlaying: Bool) {
        guard let _ = interfaceController else { return }
        
        // CarPlay allows custom dynamic subtitles on the Now Playing template
        let lyricSubtitle = currentLine.isEmpty ? artist : "♪ \(currentLine)"
        
        // Update MPNowPlayingInfoCenter / CPNowPlayingTemplate state
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = lyricSubtitle
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}