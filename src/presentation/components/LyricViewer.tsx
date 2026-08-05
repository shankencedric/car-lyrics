import React, { useEffect, useRef } from 'react';
import {
    ActivityIndicator,
    FlatList,
    StyleSheet,
    Text,
    View,
} from 'react-native';
import { LyricsLine, SyncedLyrics } from '../../domain/models/lyrics';

interface LyricViewerProps {
    lyrics: SyncedLyrics | null;
    activeLineIndex: number;
    isLoading: boolean;
}

export const LyricViewer: React.FC<LyricViewerProps> = ({
    lyrics,
    activeLineIndex,
    isLoading,
}) => {
    const flatListRef = useRef<FlatList<LyricsLine>>(null);

    // Automatically scroll to center the active line
    useEffect(() => {
        if (activeLineIndex >= 0 && flatListRef.current) {
            flatListRef.current.scrollToIndex({
                index: activeLineIndex,
                animated: true,
                viewPosition: 0.5, // Centers active line on screen
            });
        }
    }, [activeLineIndex]);

    if (isLoading) {
        return (
            <View style={styles.centered}>
                <ActivityIndicator size="large" color="#ffffff" />
                <Text style={styles.statusText}>Fetching lyrics...</Text>
            </View>
        );
    }

    if (!lyrics || lyrics.lines.length === 0) {
        return (
            <View style={styles.centered}>
                <Text style={styles.statusText}>No lyrics available for this track</Text>
            </View>
        );
    }

    const renderItem = ({ item, index }: { item: LyricsLine; index: number }) => {
        const isActive = index === activeLineIndex;

        return (
            <View style={styles.lineRow}>
                <Text
                    style={[
                        styles.lineText,
                        isActive ? styles.activeLineText : styles.inactiveLineText,
                    ]}
                >
                    {item.text || '♪'}
                </Text>
            </View>
        );
    };

    return (
        <View style={styles.container}>
            <FlatList
                ref={flatListRef}
                data={lyrics.lines}
                keyExtractor={(item, index) => `${item.timestampMs}-${index}`}
                renderItem={renderItem}
                onScrollToIndexFailed={(info) => {
                    // Smooth fallback scroll when dealing with dynamic line heights
                    flatListRef.current?.scrollToOffset({
                        offset: info.averageItemLength * info.index,
                        animated: true,
                    });
                }}
                contentContainerStyle={styles.listContent}
                showsVerticalScrollIndicator={false}
            />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#121212',
    },
    centered: {
        flex: 1,
        backgroundColor: '#121212',
        justifyContent: 'center',
        alignItems: 'center',
    },
    statusText: {
        color: '#888888',
        fontSize: 16,
        marginTop: 12,
    },
    listContent: {
        paddingVertical: '50%', 
        paddingHorizontal: 24,
    },
    lineRow: {
        paddingVertical: 11, 
        justifyContent: 'center',
        alignItems: 'center',
        width: '100%',
    },
    lineText: {
        fontSize: 22,
        fontWeight: '700',
        textAlign: 'center',
        lineHeight: 32, // Prevents text lines from overlapping when a lyric wraps
    },
    activeLineText: {
        color: '#ffffff',
        fontSize: 26,
        lineHeight: 38, // Matched line height for active font size
        opacity: 1,
    },
    inactiveLineText: {
        color: '#ffffff',
        opacity: 0.3,
    },
});