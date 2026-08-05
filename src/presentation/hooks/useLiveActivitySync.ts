import { useEffect, useRef } from 'react';
import { LiveActivityPresenter } from '../../adapters/LiveActivityPresenter';
import { SyncedLyrics, TrackMetadata } from '../../domain/models/lyrics';

export function useLiveActivitySync(
    currentTrack: TrackMetadata | null,
    lyrics: SyncedLyrics | null,
    activeLineIndex: number
    ) {
    const isActivityActiveRef = useRef<boolean>(false);
    const lastLineIndexRef = useRef<number>(-1);

    useEffect(() => {
        if (!currentTrack || !lyrics || !lyrics.isSynced || activeLineIndex < 0) {
            if (isActivityActiveRef.current) {
                LiveActivityPresenter.endActivity();
                isActivityActiveRef.current = false;
                lastLineIndexRef.current = -1;
            }
            return;
        }

        // Line didn't change; skip native bridge calls to save CPU/battery
        if (activeLineIndex === lastLineIndexRef.current) return;
        lastLineIndexRef.current = activeLineIndex;

        const currentLineText = lyrics.lines[activeLineIndex]?.text || '';
        const nextLineText = lyrics.lines[activeLineIndex + 1]?.text || '';
        const artistString = currentTrack.artists.join(', ');

        if (!isActivityActiveRef.current) {
            LiveActivityPresenter.startActivity(
                currentTrack.title,
                artistString,
                currentLineText,
                nextLineText
            );
            isActivityActiveRef.current = true;
        } else {
            LiveActivityPresenter.updateActivity(currentLineText, nextLineText);
        }
    }, [currentTrack, lyrics, activeLineIndex]);
}