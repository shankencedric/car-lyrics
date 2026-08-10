import { NativeModules, Platform } from 'react-native';

const { AppGroupModule } = NativeModules;

export class WidgetPresenter {
    private static isSupported(): boolean {
        return Platform.OS === 'ios' && Boolean(AppGroupModule);
    }

    public static updateWidget(
        title: string,
        artist: string,
        previousLine: string,
        currentLine: string,
        nextLine: string,
        followingLine: string,
        artworkUrl?: string
    ): void {
        if (!this.isSupported()) return;

        try {
            AppGroupModule.setLyricsData(
                title,
                artist,
                previousLine || '',
                currentLine || '♪',
                nextLine || '',
                followingLine || '',
                artworkUrl || ''
            );
        } catch {
            // Silently handle native bridge failures during background updates
        }
    }
}