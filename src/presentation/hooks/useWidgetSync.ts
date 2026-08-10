// src/presentation/hooks/useWidgetSync.ts
import { useEffect, useRef } from 'react';
import { WidgetPresenter } from '../../adapters/WidgetPresenter';
import { SyncedLyrics, TrackMetadata } from '../../domain/models/lyrics';

export function useWidgetSync(
    currentTrack: TrackMetadata | null,
    lyrics: SyncedLyrics | null,
    activeLineIndex: number
) {
    const lastLineIndexRef = useRef<number>(-1);

    useEffect(() => {
        if (!currentTrack) return;

        // Skip native bridge calls if the lyric line index hasn't changed
        if (activeLineIndex === lastLineIndexRef.current) return;
        lastLineIndexRef.current = activeLineIndex;

        const currentLineText =
            lyrics && lyrics.lines[activeLineIndex]
                ? lyrics.lines[activeLineIndex].text
                : '';

        const artistString = currentTrack.artists.join(', ');

        WidgetPresenter.updateWidget(
            currentTrack.title,
            artistString,
            currentLineText,
            currentTrack.artwork
        );
    }, [currentTrack, lyrics, activeLineIndex]);
}