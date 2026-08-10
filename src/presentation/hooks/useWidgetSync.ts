{\rtf1\ansi\ansicpg1252\cocoartf2870
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww19940\viewh11900\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 // src/presentation/hooks/useWidgetSync.ts\
import \{ useEffect, useRef \} from 'react';\
import \{ WidgetPresenter \} from '../../adapters/WidgetPresenter';\
import \{ SyncedLyrics, TrackMetadata \} from '../../domain/models/lyrics';\
\
export function useWidgetSync(\
    currentTrack: TrackMetadata | null,\
    lyrics: SyncedLyrics | null,\
    activeLineIndex: number\
) \{\
    const lastLineIndexRef = useRef<number>(-1);\
\
    useEffect(() => \{\
        if (!currentTrack) return;\
\
        // Skip native bridge calls if the lyric line index hasn't changed\
        if (activeLineIndex === lastLineIndexRef.current) return;\
        lastLineIndexRef.current = activeLineIndex;\
\
        const currentLineText =\
            lyrics && lyrics.lines[activeLineIndex]\
                ? lyrics.lines[activeLineIndex].text\
                : '';\
\
        const artistString = currentTrack.artists.join(', ');\
\
        WidgetPresenter.updateWidget(\
            currentTrack.title,\
            artistString,\
            currentLineText,\
            currentTrack.artwork\
        );\
    \}, [currentTrack, lyrics, activeLineIndex]);\
\}}