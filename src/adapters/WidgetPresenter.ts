// src/adapters/WidgetPresenter.ts
import { NativeModules, Platform } from 'react-native';

const { AppGroupModule } = NativeModules;

export class WidgetPresenter {
    private static isSupported(): boolean {
        return Platform.OS === 'ios' && Boolean(AppGroupModule);
    }

    public static updateWidget(
        title: string,
        artist: string,
        currentLine: string,
        artworkUrl?: string
    ): void {
        if (!this.isSupported()) return;

        try {
            AppGroupModule.setLyricsData(
                title,
                artist,
                currentLine ? `♪ ${currentLine}` : '♪ ...',
                artworkUrl || ''
            );
        } catch {
            // Gracefully handle background bridge updates
        }
    }
}