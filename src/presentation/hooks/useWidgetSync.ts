import { useEffect, useRef } from 'react';
import { AppState, AppStateStatus, NativeModules } from 'react-native';
import { SyncedLyrics, TrackMetadata } from '../../domain/models/lyrics';

const { AppGroupModule } = NativeModules;

// 2 minutes of inactivity before clearing the Lock Screen widget
const INACTIVITY_TIMEOUT_MS = 2 * 60 * 1000;

export function useWidgetSync(
  currentTrack: TrackMetadata | null,
  lyrics: SyncedLyrics | null,
  activeLineIndex: number,
  isPlaying: boolean,
  platformName: string
) {
  const inactivityTimerRef = useRef<NodeJS.Timeout | null>(null);

  // Helper to push all 8 parameters to shared App Group
  const updateWidgetData = (
    title: string,
    artist: string,
    previousLine: string,
    currentLine: string,
    nextLine: string,
    followingLine: string,
    artworkUrl: string,
    platform: string
  ) => {
    if (AppGroupModule && AppGroupModule.setLyricsData) {
      AppGroupModule.setLyricsData(
        title,
        artist,
        previousLine,
        currentLine,
        nextLine,
        followingLine,
        artworkUrl,
        platform
      );
    }
  };

  // Helper to wipe widget data
  const clearWidgetData = () => {
    updateWidgetData('', '', '', '', '', '', '', '');
  };

  useEffect(() => {
    // Clear any existing inactivity timer whenever playback state changes
    if (inactivityTimerRef.current) {
      clearTimeout(inactivityTimerRef.current);
      inactivityTimerRef.current = null;
    }

    if (!currentTrack || !isPlaying) {
      // If paused, start the 2-minute countdown to wipe the widget
      inactivityTimerRef.current = setTimeout(() => {
        clearWidgetData();
      }, INACTIVITY_TIMEOUT_MS);

      // If there's no track playing at all, clear immediately
      if (!currentTrack) {
        clearWidgetData();
        return;
      }
    }

    // Extract surrounding lyric lines for multi-line widgets
    let prevLine = '';
    let currLine = '';
    let nextLine = '';
    let followingLine = '';

    if (lyrics && lyrics.lines && activeLineIndex >= 0 && activeLineIndex < lyrics.lines.length) {
      currLine = lyrics.lines[activeLineIndex].text;

      if (activeLineIndex > 0) {
        prevLine = lyrics.lines[activeLineIndex - 1].text;
      }
      if (activeLineIndex + 1 < lyrics.lines.length) {
        nextLine = lyrics.lines[activeLineIndex + 1].text;
      }
      if (activeLineIndex + 2 < lyrics.lines.length) {
        followingLine = lyrics.lines[activeLineIndex + 2].text;
      }
    }

    // Push live data with correct 8-argument alignment
    updateWidgetData(
      currentTrack.title,
      currentTrack.artists.join(', '),
      prevLine,
      currLine,
      nextLine,
      followingLine,
      currentTrack.artworkUrl || '',
      platformName
    );
  }, [currentTrack, lyrics, activeLineIndex, isPlaying, platformName]);

  // Handle App Closing / Backgrounding
  useEffect(() => {
    const handleAppStateChange = (nextAppState: AppStateStatus) => {
      if ((nextAppState === 'background' || nextAppState === 'inactive') && !isPlaying) {
        clearWidgetData();
      }
    };

    const subscription = AppState.addEventListener('change', handleAppStateChange);
    return () => {
      subscription.remove();
      if (inactivityTimerRef.current) {
        clearTimeout(inactivityTimerRef.current);
      }
    };
  }, [isPlaying]);
}