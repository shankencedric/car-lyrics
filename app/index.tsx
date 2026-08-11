import React, { useState } from 'react';
import {
  Image,
  Modal,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { EmbeddedPlayer } from '../src/presentation/components/EmbeddedPlayer';
import { LyricViewer } from '../src/presentation/components/LyricViewer';
import { useLiveActivitySync } from '../src/presentation/hooks/useLiveActivitySync';
import { useMusicSync } from '../src/presentation/hooks/useMusicSync';
import { useWidgetSync } from '../src/presentation/hooks/useWidgetSync';

interface PlatformPreset {
  id: string;
  name: string;
  url: string;
  emoji: string;
  status: 'green' | 'yellow' | 'red';
  statusDescription: string;
}

const PLATFORM_PRESETS: PlatformPreset[] = [
  {
    id: 'ytm',
    name: 'YouTube Music',
    url: 'https://music.youtube.com',
    emoji: '🔴',
    status: 'green',
    statusDescription: 'Tested & Fully Working',
  },
  {
    id: 'spotify',
    name: 'Spotify',
    url: 'https://open.spotify.com',
    emoji: '🟢',
    status: 'yellow',
    statusDescription: "Partially working (lyrics don't scroll)",
  },
  {
    id: 'soundcloud',
    name: 'SoundCloud',
    url: 'https://soundcloud.com',
    emoji: '🟠',
    status: 'yellow',
    statusDescription: "Partially working (lyrics don't scroll)",
  },
  {
    id: 'amazon',
    name: 'Amazon Music',
    url: 'https://music.amazon.com',
    emoji: '💙',
    status: 'yellow',
    statusDescription: "Partially working (lyrics don't scroll)",
  },
  {
    id: 'apple',
    name: 'Apple Music',
    url: 'https://music.apple.com',
    emoji: '🍎',
    status: 'yellow',
    statusDescription: 'Untested',
  },
];

export default function App() {
  const [currentPlatform, setCurrentPlatform] = useState<PlatformPreset>(PLATFORM_PRESETS[0]);
  const [showLyricsOverlay, setShowLyricsOverlay] = useState<boolean>(false);
  const [showPlatformModal, setShowPlatformModal] = useState<boolean>(false);

  const {
    currentTrack,
    lyrics,
    activeLineIndex,
    isPlaying,
    isLoadingLyrics,
    handleTrackChange,
    handleTimeUpdate,
    handlePlaybackStateChange,
    resetSync,
  } = useMusicSync();

  // 1. Live Activities (Dynamic Island / Lock Screen banner)
  useLiveActivitySync(currentTrack, lyrics, activeLineIndex);

  // 2. WidgetKit (Home Screen, Lock Screen, & CarPlay Widget Stack)
  useWidgetSync(currentTrack, lyrics, activeLineIndex, isPlaying, currentPlatform.name);

  const handleSelectPlatform = (preset: PlatformPreset) => {
    if (preset.id === currentPlatform.id) {
      setShowPlatformModal(false);
      return;
    }
    resetSync(); // Clear previous platform song and lyrics immediately
    setCurrentPlatform(preset);
    setShowPlatformModal(false);
  };

  const getStatusSymbol = (status: 'green' | 'yellow' | 'red') => {
    switch (status) {
      case 'green':
        return '🟢';
      case 'yellow':
        return '🟡';
      case 'red':
        return '🔴';
    }
  };

  return (
    <GestureHandlerRootView style={styles.root}>
      <SafeAreaProvider>
        <SafeAreaView style={styles.container} edges={['top', 'left', 'right']}>
          <StatusBar barStyle="light-content" />

          {/* Fullscreen Embedded Web Player */}
          <View style={styles.fullscreenPlayer}>
            <EmbeddedPlayer
              url={currentPlatform.url}
              onTrackChange={handleTrackChange}
              onTimeUpdate={handleTimeUpdate}
              onPlaybackStateChange={handlePlaybackStateChange}
            />
          </View>

          {/* Middle-Right Floating Overlay Buttons */}
          <View style={styles.middleRightOverlayStack}>
            {/* Toggle Lyrics Overlay */}
            <TouchableOpacity
              style={[
                styles.floatingButton,
                showLyricsOverlay && styles.floatingButtonActive,
              ]}
              onPress={() => setShowLyricsOverlay(!showLyricsOverlay)}
              activeOpacity={0.8}
            >
              <Text style={styles.buttonEmoji}>🎤</Text>
            </TouchableOpacity>

            {/* Switch Platform */}
            <TouchableOpacity
              style={styles.floatingButton}
              onPress={() => setShowPlatformModal(true)}
              activeOpacity={0.8}
            >
              <Text style={styles.buttonEmoji}>{currentPlatform.emoji}</Text>
            </TouchableOpacity>
          </View>

          {/* Full-Screen Lyrics Overlay */}
          {showLyricsOverlay && (
            <View style={styles.fullScreenLyricsOverlay}>
              <SafeAreaView style={styles.fullScreenLyricsContainer} edges={['top', 'bottom', 'left', 'right']}>
                
                {/* Header: Artwork, Title, Song, and Streaming Platform Indicator */}
                <View style={styles.fullScreenHeader}>
                  {currentTrack?.artworkUrl ? (
                    <Image
                      source={{ uri: currentTrack.artworkUrl }}
                      style={styles.headerArtwork}
                    />
                  ) : (
                    <View style={[styles.headerArtwork, styles.placeholderArtwork]}>
                      <Text style={styles.placeholderIcon}>🎵</Text>
                    </View>
                  )}

                  <View style={styles.headerMeta}>
                    <Text style={styles.headerTitle} numberOfLines={1}>
                      {currentTrack ? currentTrack.title : 'No Track Playing'}
                    </Text>
                    <Text style={styles.headerArtist} numberOfLines={1}>
                      {currentTrack ? currentTrack.artists.join(', ') : 'Play music on web player'}
                    </Text>
                    <Text style={styles.streamingIndicator}>
                      streaming from {currentPlatform.name}
                    </Text>
                  </View>

                  <TouchableOpacity
                    style={styles.closeOverlayButton}
                    onPress={() => setShowLyricsOverlay(false)}
                    hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
                  >
                    <Text style={styles.closeOverlayText}>✕</Text>
                  </TouchableOpacity>
                </View>

                {/* Body: Time-Synced Full-Screen Lyric Viewer */}
                <View style={styles.fullScreenLyricsBody}>
                  <LyricViewer
                    lyrics={lyrics}
                    activeLineIndex={activeLineIndex}
                    isLoading={isLoadingLyrics}
                  />
                </View>

              </SafeAreaView>
            </View>
          )}

          {/* Platform Switcher Modal */}
          <Modal
            visible={showPlatformModal}
            transparent={true}
            animationType="slide"
            onRequestClose={() => setShowPlatformModal(false)}
          >
            <TouchableOpacity
              style={styles.modalBackdrop}
              activeOpacity={1}
              onPress={() => setShowPlatformModal(false)}
            >
              <View style={styles.modalContent} onStartShouldSetResponder={() => true}>
                <View style={styles.modalHeader}>
                  <Text style={styles.modalTitle}>Select Streaming Platform</Text>
                  <TouchableOpacity onPress={() => setShowPlatformModal(false)}>
                    <Text style={styles.closeModalText}>✕</Text>
                  </TouchableOpacity>
                </View>

                <ScrollView style={styles.presetList}>
                  {PLATFORM_PRESETS.map((item) => {
                    const isSelected = item.id === currentPlatform.id;
                    return (
                      <TouchableOpacity
                        key={item.id}
                        style={[
                          styles.presetRow,
                          isSelected && styles.presetRowSelected,
                        ]}
                        onPress={() => handleSelectPlatform(item)}
                      >
                        <Text style={styles.presetEmoji}>{item.emoji}</Text>
                        <View style={styles.presetInfo}>
                          <Text style={styles.presetName}>{item.name}</Text>
                          <Text style={styles.presetStatusDesc}>{item.statusDescription}</Text>
                        </View>
                        <Text style={styles.statusSymbol}>{getStatusSymbol(item.status)}</Text>
                      </TouchableOpacity>
                    );
                  })}
                </ScrollView>
              </View>
            </TouchableOpacity>
          </Modal>

        </SafeAreaView>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: '#000000',
  },
  container: {
    flex: 1,
    backgroundColor: '#000000',
  },
  fullscreenPlayer: {
    ...StyleSheet.absoluteFillObject,
  },

  // Middle-Right Floating Stack
  middleRightOverlayStack: {
    position: 'absolute',
    right: 16,
    top: '40%',
    transform: [{ translateY: -50 }],
    gap: 12,
    zIndex: 99,
  },
  floatingButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: 'rgba(28, 28, 30, 0.85)',
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 6,
    elevation: 8,
  },
  floatingButtonActive: {
    backgroundColor: '#30d158',
    borderColor: '#ffffff',
  },
  buttonEmoji: {
    fontSize: 22,
  },

  // Full-Screen Lyrics Overlay
  fullScreenLyricsOverlay: {
    ...StyleSheet.absoluteFillObject,
    backgroundColor: '#000000',
    zIndex: 100,
  },
  fullScreenLyricsContainer: {
    flex: 1,
    backgroundColor: '#000000',
  },
  fullScreenHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 14,
    backgroundColor: '#1c1c1e',
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#333333',
  },
  headerArtwork: {
    width: 52,
    height: 52,
    borderRadius: 8,
    marginRight: 14,
  },
  placeholderArtwork: {
    backgroundColor: '#2c2c2e',
    justifyContent: 'center',
    alignItems: 'center',
  },
  placeholderIcon: {
    fontSize: 22,
  },
  headerMeta: {
    flex: 1,
    marginRight: 10,
  },
  headerTitle: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  headerArtist: {
    color: '#dddddd',
    fontSize: 14,
    marginTop: 2,
  },
  streamingIndicator: {
    color: '#30d158',
    fontSize: 11,
    fontWeight: '600',
    marginTop: 3,
  },
  closeOverlayButton: {
    padding: 8,
  },
  closeOverlayText: {
    color: '#ffffff',
    fontSize: 20,
    fontWeight: 'bold',
  },
  fullScreenLyricsBody: {
    flex: 1,
  },

  // Modal Styles
  modalBackdrop: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#1c1c1e',
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    paddingHorizontal: 20,
    paddingTop: 16,
    paddingBottom: 40,
    maxHeight: '65%',
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingBottom: 16,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: '#333333',
  },
  modalTitle: {
    color: '#ffffff',
    fontSize: 18,
    fontWeight: 'bold',
  },
  closeModalText: {
    color: '#8e8e93',
    fontSize: 18,
    fontWeight: 'bold',
  },
  presetList: {
    marginTop: 10,
  },
  presetRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 14,
    paddingHorizontal: 12,
    borderRadius: 12,
    marginVertical: 4,
    backgroundColor: '#2c2c2e',
  },
  presetRowSelected: {
    backgroundColor: '#3a3a3c',
    borderWidth: 1,
    borderColor: '#30d158',
  },
  presetEmoji: {
    fontSize: 24,
    marginRight: 12,
  },
  presetInfo: {
    flex: 1,
  },
  presetName: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  presetStatusDesc: {
    color: '#8e8e93',
    fontSize: 12,
    marginTop: 2,
  },
  statusSymbol: {
    fontSize: 16,
    marginLeft: 8,
  },
});