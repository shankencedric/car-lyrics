import { useEffect, useRef } from 'react';
import { CarPlayPresenter } from '../../adapters/CarPlayPresenter';
import { SyncedLyrics, TrackMetadata } from '../../domain/models/lyrics';

    export function useCarPlaySync(
    currentTrack: TrackMetadata | null,
    lyrics: SyncedLyrics | null,
    activeLineIndex: number,
    isPlaying: boolean
    ) {
    const lastLineIndexRef = useRef<number>(-1);

    useEffect(() => {
        if (!currentTrack) return;

        // Avoid redundant calls if the lyric line index hasn't changed
        if (activeLineIndex === lastLineIndexRef.current) return;
        lastLineIndexRef.current = activeLineIndex;

        const currentLineText =
        lyrics && lyrics.lines[activeLineIndex]
            ? lyrics.lines[activeLineIndex].text
            : '';

        CarPlayPresenter.updateCarPlay(
        currentTrack.title,
        currentTrack.artists.join(', '),
        currentLineText,
        isPlaying
        );
    }, [currentTrack, lyrics, activeLineIndex, isPlaying]);
}