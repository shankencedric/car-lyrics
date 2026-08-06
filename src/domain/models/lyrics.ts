export interface TrackMetadata {
    title: string;
    artists: string[];
    album?: string;
    durationSecs?: number;
}

export interface LyricsLine {
    timestampMs: number; // from the start of the track
    text: string;
}

export interface SyncedLyrics {
    id?: number;
    trackName: string;
    artistNames: string[];
    lines: LyricsLine[];
    isSynced: boolean; // synced (.lrc) or plain text
}