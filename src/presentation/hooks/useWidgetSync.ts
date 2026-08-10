import { useEffect, useRef } from 'react';
import { WidgetPresenter } from '../../adapters/WidgetPresenter';
import { SyncedLyrics, TrackMetadata } from '../../domain/models/lyrics';

export function useWidgetSync(
    currentTrack: TrackMetadata | null,
    lyrics: SyncedLyrics | null,
    activeLineIndex: number
) {
    const lastLineIndexRef = useRef<number>(-1);
    const lastTrackTitleRef = useRef<string>('');

    useEffect(() => {
        if (!currentTrack) return;

        const isNewTrack = currentTrack.title !== lastTrackTitleRef.current;
        const isNewLyricLine = activeLineIndex !== lastLineIndexRef.current;

        // Skip bridge calls if neither track nor active lyric line changed
        if (!isNewTrack && !isNewLyricLine) return;

        lastLineIndexRef.current = activeLineIndex;
        lastTrackTitleRef.current = currentTrack.title;

        // Extract active lyric text safely
        const currentLineText =
            lyrics && lyrics.lines && activeLineIndex >= 0 && lyrics.lines[activeLineIndex]
                ? lyrics.lines[activeLineIndex].text
                : '';

        const artistString = currentTrack.artists ? currentTrack.artists.join(', ') : 'Unknown Artist';

        WidgetPresenter.updateWidget(
            currentTrack.title,
            artistString,
            currentLineText,
            currentTrack.artwork // Safely typed from TrackMetadata
        );
    }, [currentTrack, lyrics, activeLineIndex]);
}