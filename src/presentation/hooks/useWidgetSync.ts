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
  platformName: string,
  currentTimeMs: number = 0
) {
  const inactivityTimerRef = useRef<NodeJS.Timeout | null>(null);

  // Helper to push all 9 parameters to shared App Group
  const updateWidgetData = (
    title: string,
    artist: string,
    previousLine: string,
    currentLine: string,
    nextLine: string,
    followingLine: string,
    artworkUrl: string,
    platform: string,
    progress: number
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
        platform,
        progress
      );
    }
  };

  // Helper to wipe widget data
  const clearWidgetData = () => {
    updateWidgetData('', '', '', '', '', '', '', '', 0.0);
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

    if (lyrics && lyrics.lines && lyrics.lines.length > 0) {
      if (activeLineIndex >= 0 && activeLineIndex < lyrics.lines.length) {
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
      } else if (activeLineIndex < 0) {
        // Before track starts: display first line as 'next' so it doesn't pop in abruptly
        currLine = '';
        nextLine = lyrics.lines[0].text;
        if (lyrics.lines.length > 1) {
          followingLine = lyrics.lines[1].text;
        }
      }
    }

    // Estimate playback progress ratio (0.0 to 1.0) for circular widget gauge
    let progressRatio = 0.0;
    if (lyrics && lyrics.lines && lyrics.lines.length > 0) {
      const lastLineMs = lyrics.lines[lyrics.lines.length - 1].timestampMs;
      if (lastLineMs > 0 && typeof currentTimeMs === 'number' && !isNaN(currentTimeMs)) {
        progressRatio = Math.min(1.0, Math.max(0.0, currentTimeMs / lastLineMs));
      }
    }

    // Final sanity check before bridge call
    const safeProgress = (isNaN(progressRatio) || !isFinite(progressRatio)) ? 0.0 : progressRatio;

    updateWidgetData(
      currentTrack.title,
      currentTrack.artists.join(', '),
      prevLine,
      currLine,
      nextLine,
      followingLine,
      currentTrack.artworkUrl || '',
      platformName,
      safeProgress // Passed securely as a valid double
    );
  }, [currentTrack, lyrics, activeLineIndex, isPlaying, platformName, currentTimeMs]);

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