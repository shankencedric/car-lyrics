export interface WebPlayerEvent {
  type: 'TRACK_CHANGE' | 'TIME_UPDATE' | 'PLAYBACK_STATE';
  payload: {
    title?: string;
    artists?: string[];
    album?: string;
    durationSecs?: number;
    currentTimeMs?: number;
    isPlaying?: boolean;
  };
}

/**
 * Self-contained JS snippet executed inside react-native-webview context.
 * Communicates with React Native via window.ReactNativeWebView.postMessage.
 */
export const YTM_OBSERVER_SCRIPT = `
(function() {
    if (window.__YTM_OBSERVER_INJECTED__) return;
    window.__YTM_OBSERVER_INJECTED__ = true;

    let lastTrackId = '';
    let lastIsPlaying = false;

    function postToRN(type, payload) {
        if (window.ReactNativeWebView && window.ReactNativeWebView.postMessage) {
        window.ReactNativeWebView.postMessage(JSON.stringify({ type, payload }));
        }
    }

    function getMediaVideoElement() {
        return document.querySelector('video');
    }

    function parseArtists(bylineText) {
        if (!bylineText) return [];
        // YTM byline usually formatted as: "Artist 1, Artist 2 • Album • Year"
        const parts = bylineText.split('•').map(s => s.trim());
        const artistPart = parts[0] || '';
        return artistPart
        .split(/,|&|\\bfeat\\.\\b|\\bft\\.\\b/i)
        .map(a => a.trim())
        .filter(Boolean);
    }

    function parseAlbum(bylineText) {
        if (!bylineText) return undefined;
        const parts = bylineText.split('•').map(s => s.trim());
        // If 3 parts exist (Artist • Album • Year), index 1 is album
        return parts.length >= 2 ? parts[1] : undefined;
    }

    function extractMetadata() {
        const titleEl = document.querySelector('ytmusic-player-bar .title');
        const bylineEl = document.querySelector('ytmusic-player-bar .byline');
        const videoEl = getMediaVideoElement();

        const title = titleEl ? titleEl.textContent.trim() : '';
        const bylineText = bylineEl ? bylineEl.textContent.trim() : '';
        const artists = parseArtists(bylineText);
        const album = parseAlbum(bylineText);
        const durationSecs = videoEl && !isNaN(videoEl.duration) ? videoEl.duration : 0;

        const trackId = title + '::' + artists.join(',');

        if (trackId !== lastTrackId && title.length > 0) {
        lastTrackId = trackId;
        postToRN('TRACK_CHANGE', {
            title,
            artists,
            album,
            durationSecs
        });
        }
    }

    // 1. Monitor DOM changes for track metadata updates
    const observer = new MutationObserver(() => {
        extractMetadata();
    });

    const playerBar = document.querySelector('ytmusic-player-bar');
    if (playerBar) {
        observer.observe(playerBar, { childList: true, subtree: true, characterData: true });
    } else {
        // Retry finding player bar if not loaded yet
        const initInterval = setInterval(() => {
        const bar = document.querySelector('ytmusic-player-bar');
        if (bar) {
            observer.observe(bar, { childList: true, subtree: true, characterData: true });
            clearInterval(initInterval);
        }
        }, 1000);
    }

    // 2. High-frequency timer for exact media time sync (250ms)
    setInterval(() => {
        const videoEl = getMediaVideoElement();
        if (!videoEl) return;

        const isPlaying = !videoEl.paused && !videoEl.ended;
        const currentTimeMs = Math.floor(videoEl.currentTime * 1000);

        if (isPlaying !== lastIsPlaying) {
        lastIsPlaying = isPlaying;
        postToRN('PLAYBACK_STATE', { isPlaying });
        }

        if (isPlaying) {
        postToRN('TIME_UPDATE', { currentTimeMs });
        }
    }, 250);

    // Initial metadata check
    extractMetadata();
})();
true; // Note: Required for WebView JS injection return value
`;