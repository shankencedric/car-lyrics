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

        const lines = lyrics?.lines ?? [];

        // Safe index extraction
        const previousLineText =
            activeLineIndex > 0 && lines[activeLineIndex - 1]
                ? lines[activeLineIndex - 1].text
                : '';

        const currentLineText =
            activeLineIndex >= 0 && lines[activeLineIndex]
                ? lines[activeLineIndex].text
                : '';

        const nextLineText =
            activeLineIndex + 1 < lines.length && lines[activeLineIndex + 1]
                ? lines[activeLineIndex + 1].text
                : '';

        const followingLineText =
            activeLineIndex + 2 < lines.length && lines[activeLineIndex + 2]
                ? lines[activeLineIndex + 2].text
                : '';

        const artistString = currentTrack.artists ? currentTrack.artists.join(', ') : 'Unknown Artist';

        WidgetPresenter.updateWidget(
            currentTrack.title,
            artistString,
            previousLineText,
            currentLineText,
            nextLineText,
            followingLineText,
            currentTrack.artwork
        );
    }, [currentTrack, lyrics, activeLineIndex]);
}