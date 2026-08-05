import { SyncedLyrics, TrackMetadata } from '../models/lyrics';

export interface ILyricsRepository {
  /**
   * Fetches lyrics for a given track metadata.
   * Returns SyncedLyrics object if found, or null if no match exists.
   */
  getLyrics(track: TrackMetadata): Promise<SyncedLyrics | null>;
}