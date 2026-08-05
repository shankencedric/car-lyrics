import { LyricsLine } from '../models/lyrics';

export class LrcParser {
    /**
     * Parses a raw LRC string into an array of ordered LyricsLine objects.
     * @param rawLrc Raw LRC text string containing timestamp tags like [mm:ss.xx]
     * @returns Array of LyricsLine sorted chronologically by timestamp
     */
    public static parse(rawLrc: string): LyricsLine[] {
        if (!rawLrc || typeof rawLrc !== 'string') 
        return [];

        const lines = rawLrc.split(/\r?\n/);
        const parsedLines: LyricsLine[] = [];

        // Match standard LRC timestamp tags like [01:23.45] or [01:23.456]
        const timestampRegex = /\[(\d{2}):(\d{2})\.(\d{2,3})\]/g;

        for (const line of lines) {
            const cleanLine = line.trim();
            if (!cleanLine) continue;

            // Extract all timestamps found in a single line
            const timestamps: number[] = [];
            let match: RegExpExecArray | null;

            // Reset regex index for safety
            timestampRegex.lastIndex = 0;

            while ((match = timestampRegex.exec(cleanLine)) !== null) {
                const minutes = parseInt(match[1], 10);
                const seconds = parseInt(match[2], 10);
                let fractionStr = match[3];

                // Normalize fraction to 3-digit milliseconds (e.g. .45 -> 450ms, .456 -> 456ms)
                if (fractionStr.length === 2) 
                    fractionStr = fractionStr + '0';

                const milliseconds = parseInt(fractionStr, 10);

                const totalMs = minutes * 60 * 1000 + seconds * 1000 + milliseconds;
                timestamps.push(totalMs);
            }

            // If timestamps were found, strip them out to isolate the lyric text
            if (timestamps.length > 0) {
                const text = cleanLine.replace(/\[\d{2}:\d{2}\.\d{2,3}\]/g, '').trim();

                for (const timestampMs of timestamps) {
                    parsedLines.push({ timestampMs, text });
                }
            }
        }

        // Always ensure parsed lines are chronologically ordered
        return parsedLines.sort((a, b) => a.timestampMs - b.timestampMs);
    }
}