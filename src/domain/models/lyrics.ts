export interface TrackMetadata {
    title: string;
    artists: string[];
    album?: string;
    durationSecs?: number;
    artwork?: string; // Added optional artwork thumbnail URL
}

export interface LyricsLine {
    timestampMs: number; // timestamp from the start of the track in ms
    text: string;
}

export interface SyncedLyrics {
    id?: number;
    trackName: string;
    artistNames: string[];
    lines: LyricsLine[];
    isSynced: boolean; // true for synced (.lrc), false for plain text
}