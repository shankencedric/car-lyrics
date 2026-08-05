import { SyncedLyrics, TrackMetadata } from '../../domain/models/lyrics';
import { ILyricsRepository } from '../../domain/repositories/ILyricsRepository';
import { LrcParser } from '../../domain/services/LrcParser';

interface LrclibResponse {
    id: number;
    trackName: string;
    artistName: string;
    albumName?: string;
    duration?: number;
    instrumental?: boolean;
    syncedLyrics?: string;
    plainLyrics?: string;
}

export class LrclibRepository implements ILyricsRepository {
    private readonly baseUrl = 'https://lrclib.net/api';

    /**
     * Mandatory client identification header required by LRCLIB documentation.
     */
    private readonly headers: HeadersInit = {
        'Lrclib-Client': 'car-lyrics/1.0.0 (https://github.com/shankencedric/car-lyrics)',
    };

    async getLyrics(track: TrackMetadata): Promise<SyncedLyrics | null> {
        if (!track.artists || track.artists.length === 0 || !track.title) 
            return null;

        const sanitizedTitle = this.sanitizeSearchTerm(track.title);
        const primaryArtist = this.sanitizeSearchTerm(track.artists[0]);

        // 1. Exact Waterfall Attempt
        const exactMatch = await this.tryExactWaterfall(
            sanitizedTitle,
            track.artists,
            track.album,
            track.durationSecs
        );
        if (exactMatch) 
            return this.transformResponse(exactMatch);

        // 2. Structured Search Attempt (handles multi-artist fuzzy matching naturally)
        await this.throttle();
        const structuredSearchMatch = await this.fetchStructuredSearch(sanitizedTitle, primaryArtist);
        if (structuredSearchMatch) 
            return this.transformResponse(structuredSearchMatch);

        // 3. Keyword Search Fallback
        await this.throttle();
        const keywordMatch = await this.fetchKeywordSearch(`${primaryArtist} ${sanitizedTitle}`);
        if (keywordMatch) 
            return this.transformResponse(keywordMatch);

        return null;
    }

    private async tryExactWaterfall(
        title: string,
        artists: string[],
        album?: string,
        duration?: number
    ): Promise<LrclibResponse | null> {
            const primaryArtist = this.sanitizeSearchTerm(artists[0]);
            const artistVariants = [
            primaryArtist,
            ...(artists.length > 1 ? [artists.map((a) => this.sanitizeSearchTerm(a)).join(' & ')] : []),
        ];

        for (const artist of artistVariants) {
            // Step A: Try exact match WITH duration constraint (strict ±2s)
            if (duration && duration > 0) {
                const match = await this.fetchExact(title, artist, album, duration);
                if (match) return match;
                await this.throttle();
            }

            // Step B: Try exact match WITHOUT duration (fallback in case YouTube Music duration includes video intro/outro)
            const matchNoDuration = await this.fetchExact(title, artist, album);
            if (matchNoDuration) return matchNoDuration;

            await this.throttle();
        }

        return null;
    }

    private async fetchExact(
        trackName: string,
        artistName: string,
        albumName?: string,
        duration?: number
    ): Promise<LrclibResponse | null> {
        const params = new URLSearchParams({
        track_name: trackName,
        artist_name: artistName,
        });

        if (albumName) 
            params.append('album_name', albumName);

        if (duration && duration > 0 && duration <= 3600) 
            params.append('duration', Math.round(duration).toString());

        return this.executeFetch<LrclibResponse>(`${this.baseUrl}/get?${params.toString()}`);
    }

    private async fetchStructuredSearch(trackName: string, artistName: string): Promise<LrclibResponse | null> {
        const params = new URLSearchParams({
            track_name: trackName,
            artist_name: artistName,
        });

        const results = await this.executeFetch<LrclibResponse[]>(`${this.baseUrl}/search?${params.toString()}`);
        return this.pickBestSearchResult(results);
    }

    private async fetchKeywordSearch(query: string): Promise<LrclibResponse | null> {
        const params = new URLSearchParams({ q: query });
        const results = await this.executeFetch<LrclibResponse[]>(`${this.baseUrl}/search?${params.toString()}`);
        return this.pickBestSearchResult(results);
    }

    private pickBestSearchResult(results: LrclibResponse[] | null): LrclibResponse | null {
        if (!results || !Array.isArray(results) || results.length === 0) 
            return null;

        // Prefer results with time-synced lyrics first, otherwise fallback to first result
        return results.find((r) => r.syncedLyrics && r.syncedLyrics.trim().length > 0) ?? results[0];
    }

    /**
     * Universal safe fetch execution incorporating rate-limiting compliance and headers.
     */
    private async executeFetch<T>(url: string): Promise<T | null> {
        try {
            const response = await fetch(url, { headers: this.headers });

            // Handle LRCLIB Rate Limits strictly as specified in documentation
            if (response.status === 429) {
                const retryAfterSecs = parseInt(response.headers.get('Retry-After') || '2', 10);
                await new Promise((resolve) => setTimeout(resolve, retryAfterSecs * 1000));
                return null;
            }

            if (!response.ok) return null;
            return (await response.json()) as T;
        } catch {
        return null;
        }
    }

    /**
     * Respects LRCLIB Request Throttling requirement (200ms delay between sequential calls).
     */
    private async throttle(ms: number = 200): Promise<void> {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }

    private transformResponse(response: LrclibResponse): SyncedLyrics {
        if (response.instrumental) 
            return {
                id: response.id,
                trackName: response.trackName,
                artistNames: this.parseArtistString(response.artistName),
                isSynced: false,
                lines: [{ timestampMs: 0, text: '♪ Instrumental Track ♪' }],
            };

        const hasSynced = Boolean(response.syncedLyrics && response.syncedLyrics.trim().length > 0);
        const rawContent = hasSynced ? response.syncedLyrics! : response.plainLyrics || 'No lyrics available';

        return {
            id: response.id,
            trackName: response.trackName,
            artistNames: this.parseArtistString(response.artistName),
            isSynced: hasSynced,
            lines: hasSynced ? LrcParser.parse(rawContent) : [{ timestampMs: 0, text: rawContent }],
        };
    }

    private parseArtistString(rawArtist: string): string[] {
        if (!rawArtist) return [];
        return rawArtist
            .split(/,|\s+&\s+|\s+feat\.\s+|\s+ft\.\s+/i)
            .map((a) => a.trim())
            .filter((a) => a.length > 0);
    }

    private sanitizeSearchTerm(term: string): string {
        return term
            .replace(/[\(\[\{].*?(official|video|remastered|version|feat|ft\.).*?[\)\]\}]/gi, '')
            .replace(/\s+/g, ' ')
            .trim();
    }
}