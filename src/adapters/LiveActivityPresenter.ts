import { NativeModules, Platform } from 'react-native';

const { LyricsActivityModule } = NativeModules;

export class LiveActivityPresenter {
    private static isSupported(): boolean {
        return Platform.OS === 'ios' && Boolean(LyricsActivityModule);
    }

    public static async startActivity(
        trackTitle: string,
        artistName: string,
        currentLine: string,
        nextLine: string = ''
    ): Promise<void> {
        if (!this.isSupported()) return;

        try {
            await LyricsActivityModule.startActivity(
                trackTitle,
                artistName,
                currentLine,
                nextLine
            );
        } catch {
            // Gracefully handle activity startup failure
        }
    }

    public static async updateActivity(
        currentLine: string,
        nextLine: string = ''
    ): Promise<void> {
        if (!this.isSupported()) return;

        try {
            await LyricsActivityModule.updateActivity(currentLine, nextLine);
        } catch {
            // Gracefully handle background update throttles
        }
    }

    public static async endActivity(): Promise<void> {
        if (!this.isSupported()) return;

        try {
            await LyricsActivityModule.endActivity();
        } catch {
            // Gracefully handle activity termination error
        }
    }
}