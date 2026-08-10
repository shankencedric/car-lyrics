//
//  CarLyricsWidget.swift
//  CarLyricsWidget
//
//  Created by Sean Ken Cedric Legara on 8/10/26.
//

import WidgetKit
import SwiftUI

// 1. Entry model holding track metadata and current lyric line
struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let artist: String
    let lyric: String
}

// 2. TimelineProvider reading from shared App Group UserDefaults
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            title: "Song Title",
            artist: "Artist Name",
            lyric: "♪ Synchronized lyrics will appear here"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(fetchSharedEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = fetchSharedEntry()
        // Refresh every 15 minutes, or on-demand when React Native calls AppGroupModule
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchSharedEntry() -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.com.shankencedric.carlyrics")
        let title = defaults?.string(forKey: "currentTitle") ?? "No Track Playing"
        let artist = defaults?.string(forKey: "currentArtist") ?? "Car Lyrics"
        let lyric = defaults?.string(forKey: "currentLyric") ?? "♪ Play music to display lyrics"

        return SimpleEntry(date: Date(), title: title, artist: artist, lyric: lyric)
    }
}

// 3. SwiftUI view for Home Screen, Lock Screen, and CarPlay widget stacks
struct CarLyricsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "music.note")
                    .foregroundColor(.green)
                Text(entry.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }

            Text(entry.artist)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)

            Spacer()

            Text(entry.lyric)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.8)

            Spacer()
        }
        .padding()
        .containerBackground(.black, for: .widget)
    }
}

// 4. Main Widget configuration (using StaticConfiguration)
struct CarLyricsWidget: Widget {
    let kind: String = "CarLyricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CarLyricsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Car Lyrics")
        .description("Displays real-time song lyrics on your Home Screen, Lock Screen, and CarPlay widget stack.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

// 5. Xcode Canvas Preview with realistic song data
#Preview(as: .systemMedium) {
    CarLyricsWidget()
} timeline: {
    SimpleEntry(date: .now, title: "Bohemian Rhapsody", artist: "Queen", lyric: "♪ Is this the real life? Is this just fantasy?")
    SimpleEntry(date: .now, title: "Hotel California", artist: "Eagles", lyric: "♪ Welcome to the Hotel California")
}
