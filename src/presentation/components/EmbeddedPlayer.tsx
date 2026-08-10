// src/presentation/components/EmbeddedPlayer.tsx
import React from 'react';
import { StyleSheet, View } from 'react-native';
import { WebView } from 'react-native-webview';
import { YTM_OBSERVER_SCRIPT } from '../../data/scripts/ytmObserver';

const BACKGROUND_PLAYBACK_BYPASS = `
  (function() {
    try {
      Object.defineProperty(document, 'hidden', { get: function() { return false; }, configurable: true });
      Object.defineProperty(document, 'visibilityState', { get: function() { return 'visible'; }, configurable: true });
      
      var stopVisibilityEvents = function(e) {
        if (e.type === 'visibilitychange' || e.type === 'webkitvisibilitychange') {
          e.stopImmediatePropagation();
        }
      };

      window.addEventListener('visibilitychange', stopVisibilityEvents, true);
      window.addEventListener('webkitvisibilitychange', stopVisibilityEvents, true);
      document.addEventListener('visibilitychange', stopVisibilityEvents, true);
    } catch (err) {}
  })();
  true;
`;

interface EmbeddedPlayerProps {
  onTrackChange?: (track: any) => void;
  onTimeUpdate?: (timeMs: number) => void;
  onPlaybackStateChange?: (isPlaying: boolean) => void;
  onMessage?: (event: any) => void;
}

export function EmbeddedPlayer({
  onTrackChange,
  onTimeUpdate,
  onPlaybackStateChange,
  onMessage,
}: EmbeddedPlayerProps) {

  const handleBridgeMessage = (event: any) => {
    // Forward to generic onMessage if provided
    if (onMessage) {
      onMessage(event);
    }

    try {
      const data = JSON.parse(event.nativeEvent.data);

      if (data.type === 'TRACK_CHANGE' && onTrackChange) {
        onTrackChange(data.payload);
      } else if (data.type === 'TIME_UPDATE') {
        const payload = data.payload;
        const timeMs = typeof payload === 'number' ? Math.round(payload * 1000) : Math.round((payload.currentTime || 0) * 1000);

        if (onTimeUpdate) {
          onTimeUpdate(timeMs);
        }
        if (onPlaybackStateChange && typeof payload === 'object' && payload.isPlaying !== undefined) {
          onPlaybackStateChange(payload.isPlaying);
        }
        if (onTrackChange && typeof payload === 'object' && payload.title) {
          onTrackChange({
            title: payload.title,
            artists: payload.artist ? [payload.artist] : ['Unknown Artist'],
            artworkUrl: payload.artworkUrl || '',
          });
        }
      } else if (data.type === 'PLAYBACK_STATE' && onPlaybackStateChange) {
        onPlaybackStateChange(data.payload.isPlaying);
      }
    } catch {
      // Ignore non-JSON messages
    }
  };

  return (
    <View style={styles.container}>
      <WebView
        source={{ uri: 'https://music.youtube.com' }}
        injectedJavaScriptBeforeContentLoaded={BACKGROUND_PLAYBACK_BYPASS}
        injectedJavaScript={YTM_OBSERVER_SCRIPT}
        onMessage={handleBridgeMessage}

        allowsInlineMediaPlayback={true}
        mediaPlaybackRequiresUserAction={false}
        allowsBackgroundMediaPlayback={true}
        
        javaScriptEnabled={true}
        domStorageEnabled={true}
        originWhitelist={['*']}
        userAgent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
        style={styles.webview}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#1c1c1e' },
  webview: { flex: 1, backgroundColor: '#000000' },
});