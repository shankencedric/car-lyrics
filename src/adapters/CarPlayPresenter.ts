import { NativeModules, Platform } from 'react-native';

const { CarPlayBridgeModule } = NativeModules;

export class CarPlayPresenter {
    private static isSupported(): boolean {
        return Platform.OS === 'ios' && Boolean(CarPlayBridgeModule);
    }

    public static async updateCarPlay(
        title: string,
        artist: string,
        currentLine: string,
        isPlaying: boolean
    ): Promise<void> {
        if (!this.isSupported()) return;

        try {
            await CarPlayBridgeModule.updateCarPlayLyrics(
                title,
                artist,
                currentLine,
                isPlaying
            );
        } catch {
            // Handle background bridge updates gracefully
        }
    }
}