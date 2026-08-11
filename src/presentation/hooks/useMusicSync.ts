import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
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

    // Anchor Reference for local background extrapolation
    const syncAnchorRef = useRef<{
        baseTimeMs: number;
        isPlaying: boolean;
        timestamp: number;
    }>({
        baseTimeMs: 0,
        isPlaying: false,
        timestamp: Date.now(),
    });

    // Reset sync state when switching streaming platforms
    const resetSync = useCallback(() => {
        activeTrackKeyRef.current = '';
        setCurrentTrack(null);
        setLyrics(null);
        setCurrentTimeMs(0);
        setIsPlaying(false);
        setIsLoadingLyrics(false);
        syncAnchorRef.current = {
            baseTimeMs: 0,
            isPlaying: false,
            timestamp: Date.now(),
        };
    }, []);

    // 1. Fetch Lyrics from LrclibRepository
    const handleTrackChange = useCallback(async (newTrack: TrackMetadata) => {
        if (!newTrack || !newTrack.title) return;

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

    // 2. Handle Time Updates & Sync Anchor
    const handleTimeUpdate = useCallback((timeMs: number) => {
        syncAnchorRef.current = {
            baseTimeMs: timeMs,
            isPlaying: syncAnchorRef.current.isPlaying,
            timestamp: Date.now(),
        };
        setCurrentTimeMs(timeMs);
    }, []);

    // 3. Handle Playback State Change
    const handlePlaybackStateChange = useCallback((playing: boolean) => {
        syncAnchorRef.current = {
            baseTimeMs: syncAnchorRef.current.baseTimeMs,
            isPlaying: playing,
            timestamp: Date.now(),
        };
        setIsPlaying(playing);
    }, []);

    // 4. Native React Native Local Extrapolation Loop
    useEffect(() => {
        const interval = setInterval(() => {
            const { baseTimeMs, isPlaying: playing, timestamp } = syncAnchorRef.current;
            if (!playing) return;

            const elapsedMs = Date.now() - timestamp;
            setCurrentTimeMs(baseTimeMs + elapsedMs);
        }, 150);

        return () => clearInterval(interval);
    }, []);

    // 5. Compute Active Lyric Line Index
    const activeLineIndex = useMemo(() => {
        if (!lyrics || !lyrics.isSynced || lyrics.lines.length === 0) 
            return -1;

        let activeIndex = -1;
        for (let i = 0; i < lyrics.lines.length; i++) {
            if (lyrics.lines[i].timestampMs <= currentTimeMs) 
                activeIndex = i;
            else break;
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
        resetSync,
    };
}