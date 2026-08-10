import { StatusBar, StyleSheet, Text, View } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { EmbeddedPlayer } from '../src/presentation/components/EmbeddedPlayer';
import { LyricViewer } from '../src/presentation/components/LyricViewer';
import { useLiveActivitySync } from '../src/presentation/hooks/useLiveActivitySync';
import { useMusicSync } from '../src/presentation/hooks/useMusicSync';
import { useWidgetSync } from '../src/presentation/hooks/useWidgetSync';

export default function App() {
    const {
        currentTrack,
        lyrics,
        activeLineIndex,
        isLoadingLyrics,
        handleTrackChange,
        handleTimeUpdate,
        handlePlaybackStateChange,
    } = useMusicSync();

    // 1. Live Activities (Dynamic Island / Lock Screen banner)
    useLiveActivitySync(currentTrack, lyrics, activeLineIndex);

    // 2. WidgetKit (Home Screen, Lock Screen, & CarPlay Widget Stack)
    useWidgetSync(currentTrack, lyrics, activeLineIndex);

    return (
        <SafeAreaProvider>
            <SafeAreaView style={styles.container} edges={['top', 'left', 'right']}>
                <StatusBar barStyle="light-content" />

                {/* Top Half: Embedded Web Player */}
                <View style={styles.playerContainer}>
                    <EmbeddedPlayer
                        onTrackChange={handleTrackChange}
                        onTimeUpdate={handleTimeUpdate}
                        onPlaybackStateChange={handlePlaybackStateChange}
                    />
                </View>

                {/* Middle Bar: Active Track Header */}
                <View style={styles.trackHeader}>
                    <Text style={styles.trackTitle} numberOfLines={1}>
                        {currentTrack ? currentTrack.title : 'Waiting for YouTube Music...'}
                    </Text>
                    <Text style={styles.trackArtist} numberOfLines={1}>
                        {currentTrack ? currentTrack.artists.join(', ') : 'Play a song to begin'}
                    </Text>
                </View>

                {/* Bottom Half: Time-Synced Lyric Viewer */}
                <View style={styles.lyricsContainer}>
                    <LyricViewer
                        lyrics={lyrics}
                        activeLineIndex={activeLineIndex}
                        isLoading={isLoadingLyrics}
                    />
                </View>
            </SafeAreaView>
        </SafeAreaProvider>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#000000',
    },
    playerContainer: {
        height: '40%',
        width: '100%',
    },
    trackHeader: {
        paddingHorizontal: 20,
        paddingVertical: 12,
        backgroundColor: '#1c1c1e',
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: '#333333',
    },
    trackTitle: {
        color: '#ffffff',
        fontSize: 16,
        fontWeight: 'bold',
    },
    trackArtist: {
        color: '#aaaaaa',
        fontSize: 14,
        marginTop: 2,
    },
    lyricsContainer: {
        flex: 1,
    },
});