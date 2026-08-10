import { useCallback, useMemo, useRef, useState } from 'react';
import { LrclibRepository } from '../../data/repositories/LrclibRepository';
import { SyncedLyrics, TrackMetadata } from '../../domain/models/lyrics';

const lyricsRepository = new LrclibRepository();

export function useMusicSync() {

    const [currentTrack, setCurrentTrack] = useState<TrackMetadata | null>(null);
    const [lyrics, setLyrics] = useState<SyncedLyrics | null>(null);
    const [currentTimeMs, setCurrentTimeMs] = useState<number>(0);
    const [isPlaying, setIsPlaying] = useState<boolean>(false);
    const [isLoadingLyrics, setIsLoadingLyrics] = useState<boolean>(false);

    // Track key reference to prevent duplicate API fetches for the same song
    const activeTrackKeyRef = useRef<string>('');

    const handleTrackChange = useCallback(async (newTrack: TrackMetadata) => {
        const trackKey = `${newTrack.title}::${newTrack.artists.join(',')}`;
        if (trackKey === activeTrackKeyRef.current) return;

        activeTrackKeyRef.current = trackKey;
        setCurrentTrack(newTrack);
        setCurrentTimeMs(0);
        setIsLoadingLyrics(true);

        try {
            const fetchedLyrics = await lyricsRepository.getLyrics(newTrack);
            setLyrics(fetchedLyrics);
        } catch {
            setLyrics(null);
        } finally {
            setIsLoadingLyrics(false);
        }
    }, []);

    const handleTimeUpdate = useCallback((timeMs: number) => {
        setCurrentTimeMs(timeMs);
    }, []);

    const handlePlaybackStateChange = useCallback((playing: boolean) => {
        setIsPlaying(playing);
    }, []);

    /**
     * Computes the currently active line index by finding the last line
     * whose timestamp is less than or equal to the current playback time.
     */
    const activeLineIndex = useMemo(() => {
        if (!lyrics || !lyrics.isSynced || lyrics.lines.length === 0) 
            return -1;

        let activeIndex = -1;
        for (let i = 0; i < lyrics.lines.length; i++) {
            if (lyrics.lines[i].timestampMs <= currentTimeMs) 
                activeIndex = i;
            else break; // Lines are sorted chronologically
        }
        
        return activeIndex;
    }, [lyrics, currentTimeMs]);

    return {
        currentTrack,
        lyrics,
        currentTimeMs,
        isPlaying,
        isLoadingLyrics,
        activeLineIndex,
        handleTrackChange,
        handleTimeUpdate,
        handlePlaybackStateChange,
    };
}