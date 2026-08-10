// src/data/scripts/ytmObserver.ts

export const YTM_OBSERVER_SCRIPT = `
  (function() {
    if (window.__YTM_OBSERVER_RUNNING__) return;
    window.__YTM_OBSERVER_RUNNING__ = true;

    let lastTitle = '';
    let lastArtist = '';

    function getMetadata() {
      let title = '';
      let artist = '';
      let artworkUrl = '';

      // 1. Primary: MediaSession API
      if (navigator.mediaSession && navigator.mediaSession.metadata) {
        title = navigator.mediaSession.metadata.title || '';
        artist = navigator.mediaSession.metadata.artist || '';
        if (navigator.mediaSession.metadata.artwork && navigator.mediaSession.metadata.artwork.length > 0) {
          artworkUrl = navigator.mediaSession.metadata.artwork[navigator.mediaSession.metadata.artwork.length - 1].src || '';
        }
      }

      // 2. Fallback: DOM Selectors
      if (!title) {
        const titleEl = document.querySelector('ytmusic-player-bar .title, .player-metadata .title, .title.ytmusic-player-bar');
        if (titleEl && titleEl.textContent) title = titleEl.textContent.trim();
      }
      if (!artist) {
        const artistEl = document.querySelector('ytmusic-player-bar .byline, .player-metadata .artist, .byline.ytmusic-player-bar');
        if (artistEl && artistEl.textContent) artist = artistEl.textContent.trim();
      }
      if (!artworkUrl) {
        const imgEl = document.querySelector('ytmusic-player-bar img, .player-metadata img, img.ytmusic-player-bar');
        if (imgEl && imgEl.src) artworkUrl = imgEl.src;
      }

      return { title, artist, artworkUrl };
    }

    function emitSync() {
      try {
        const { title, artist, artworkUrl } = getMetadata();
        const media = document.querySelector('video, audio');

        const currentTime = media ? (media.currentTime || 0) : 0;
        const isPlaying = media ? (!media.paused && !media.ended && media.readyState > 1) : false;

        // Emit track change if metadata updated
        if (title && (title !== lastTitle || artist !== lastArtist)) {
          lastTitle = title;
          lastArtist = artist;

          window.ReactNativeWebView.postMessage(JSON.stringify({
            type: 'TRACK_CHANGE',
            payload: { title, artists: [artist || 'Unknown Artist'], artworkUrl }
          }));
        }

        // Emit time/state snapshot
        window.ReactNativeWebView.postMessage(JSON.stringify({
          type: 'TIME_UPDATE',
          payload: {
            title,
            artist,
            artworkUrl,
            currentTime,
            isPlaying,
            timestamp: Date.now()
          }
        }));
      } catch (e) {}
    }

    // Attach native media listeners when video element is found
    function attachListeners() {
      const media = document.querySelector('video, audio');
      if (media && !media.__hasSyncListeners) {
        media.__hasSyncListeners = true;
        ['play', 'pause', 'seeking', 'seeked', 'ratechange', 'timeupdate'].forEach(function(evt) {
          media.addEventListener(evt, emitSync);
        });
      }
    }

    // Poll periodically for metadata and media attachment
    setInterval(function() {
      attachListeners();
      emitSync();
    }, 500);
  })();
  true;
`;