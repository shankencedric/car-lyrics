import React, { useRef } from 'react';
import { StyleSheet, View } from 'react-native';
import { WebView, WebViewMessageEvent } from 'react-native-webview';
import { WebPlayerEvent, YTM_OBSERVER_SCRIPT } from '../../data/scripts/ytmObserver';
import { TrackMetadata } from '../../domain/models/lyrics';

interface EmbeddedPlayerProps {
    onTrackChange: (track: TrackMetadata) => void;
    onTimeUpdate: (currentTimeMs: number) => void;
    onPlaybackStateChange: (isPlaying: boolean) => void;
}

export const EmbeddedPlayer: React.FC<EmbeddedPlayerProps> = ({
    onTrackChange,
    onTimeUpdate,
    onPlaybackStateChange,
    }) => {
    const webViewRef = useRef<React.ComponentRef<typeof WebView>>(null);

    const handleBridgeMessage = (event: WebViewMessageEvent) => {
        try {
        const message: WebPlayerEvent = JSON.parse(event.nativeEvent.data);

        switch (message.type) {
            case 'TRACK_CHANGE':
                if (message.payload.title && message.payload.artists)
                    onTrackChange({
                        title: message.payload.title,
                        artists: message.payload.artists,
                        album: message.payload.album,
                        durationSecs: message.payload.durationSecs,
                    });
                break;

            case 'TIME_UPDATE':
                if (typeof message.payload.currentTimeMs === 'number')
                    onTimeUpdate(message.payload.currentTimeMs);
                break;

            case 'PLAYBACK_STATE':
                if (typeof message.payload.isPlaying === 'boolean')
                    onPlaybackStateChange(message.payload.isPlaying);
                break;

            default:
                break;
        }
        } catch {
        // Ignore unparseable non-JSON webview messages
        }
    };

    return (
        <View style={styles.container}>
            <WebView
                ref={webViewRef}
                source={{ uri: 'https://music.youtube.com' }}
                // 1. Critical for standalone iOS media execution
                allowsInlineMediaPlayback={true}
                mediaPlaybackRequiresUserAction={false}
                javaScriptEnabled={true}
                domStorageEnabled={true}
                originWhitelist={['*']}
                // 2. Prevents YouTube from blocking standalone iOS WebViews
                userAgent="Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1"
                // 3. Catch WebContent crashes and errors
                onError={(syntheticEvent) => {
                const { nativeEvent } = syntheticEvent;
                console.warn('WebView Error:', nativeEvent);
                }}
                onRenderProcessGone={(syntheticEvent) => {
                const { nativeEvent } = syntheticEvent;
                console.warn('WebView Process Terminated:', nativeEvent.didCrash);
                }}
                style={styles.webview}

                injectedJavaScript={YTM_OBSERVER_SCRIPT}
                onMessage={handleBridgeMessage}
            />
        </View>
    );
    };

    const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#1c1c1e',
    },
    webview: {
        flex: 1,
        backgroundColor: '#000000',
    },
});