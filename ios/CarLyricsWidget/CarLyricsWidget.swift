//
//  CarLyricsWidget.swift
//  CarLyricsWidget
//
//  Created by Sean Ken Cedric Legara on 8/10/26.
//

import WidgetKit
import SwiftUI

// MARK: - App Group & Key Definitions
private enum AppGroup {
    static let suiteName = "group.com.shankencedric.carlyrics"
    
    enum Keys {
        // Base keys matching existing setup
        static let currentTitle = "currentTitle"
        static let currentArtist = "currentArtist"
        static let currentLyric = "currentLyric"
        
        // Extended keys for multi-line support
        static let trackTitle = "trackTitle"
        static let artistName = "artistName"
        static let activeLyric = "activeLyric"
        static let nextLyric = "nextLyric"
        static let followingLyric = "followingLyric"
        static let progress = "progress"
        static let artworkPath = "artworkPath"
    }
}

// MARK: - Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let artist: String
    let lyric: String
    let nextLyric: String?
    let followingLyric: String?
    let progress: Double
    let artworkImage: UIImage?

    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: Date(),
            title: "Bohemian Rhapsody",
            artist: "Queen",
            lyric: "Is this the real life? Is this just fantasy?",
            nextLyric: "Caught in a landslide, no escape from reality",
            followingLyric: "Open your eyes, look up to the skies and see",
            progress: 0.35,
            artworkImage: nil
        )
    }

    static var empty: SimpleEntry {
        SimpleEntry(
            date: Date(),
            title: "No Track Playing",
            artist: "Car Lyrics",
            lyric: "♪ Play music to display lyrics",
            nextLyric: nil,
            followingLyric: nil,
            progress: 0.0,
            artworkImage: nil
        )
    }
}

// MARK: - Timeline Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            completion(fetchSharedEntry())
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = fetchSharedEntry()
        // Refresh every 15 minutes, or on-demand when React Native calls AppGroupModule
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchSharedEntry() -> SimpleEntry {
        let defaults = UserDefaults(suiteName: AppGroup.suiteName)

        // Read with fallback to support both legacy and enhanced bridge keys
        let title = defaults?.string(forKey: AppGroup.Keys.currentTitle)
            ?? defaults?.string(forKey: AppGroup.Keys.trackTitle)
            ?? "No Track Playing"

        let artist = defaults?.string(forKey: AppGroup.Keys.currentArtist)
            ?? defaults?.string(forKey: AppGroup.Keys.artistName)
            ?? "Car Lyrics"

        let lyric = defaults?.string(forKey: AppGroup.Keys.currentLyric)
            ?? defaults?.string(forKey: AppGroup.Keys.activeLyric)
            ?? "♪ Play music to display lyrics"

        let nextLyric = defaults?.string(forKey: AppGroup.Keys.nextLyric)
        let followingLyric = defaults?.string(forKey: AppGroup.Keys.followingLyric)
        let progress = defaults?.double(forKey: AppGroup.Keys.progress) ?? 0.0

        var artworkImage: UIImage? = nil
        if let artworkPath = defaults?.string(forKey: AppGroup.Keys.artworkPath),
           let image = UIImage(contentsOfFile: artworkPath) {
            artworkImage = image
        }

        return SimpleEntry(
            date: Date(),
            title: title,
            artist: artist,
            lyric: lyric,
            nextLyric: nextLyric,
            followingLyric: followingLyric,
            progress: progress,
            artworkImage: artworkImage
        )
    }
}

// MARK: - 1. Inline Widget View (accessoryInline)
struct AccessoryInlineView: View {
    let entry: SimpleEntry

    var body: some View {
        ViewThatFits {
            // Option 1: Title + Active Lyric
            Text("♪ \(entry.title): \(entry.lyric)")
                .lineLimit(1)

            // Option 2: Active Lyric with music note
            Text("♪ \(entry.lyric)")
                .lineLimit(1)

            // Option 3: Active Lyric only (Priority 1 fallback)
            Text(entry.lyric)
                .lineLimit(1)
        }
    }
}

// MARK: - 2. Rectangular Accessory View (accessoryRectangular)
struct AccessoryRectangularView: View {
    let entry: SimpleEntry

    var body: some View {
        ViewThatFits(in: .vertical) {
            // Option A: Title Header + Active Lyric Line
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                        .font(.caption2)
                    Text(entry.title)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                }
                .foregroundColor(.secondary)

                Text(entry.lyric)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }

            // Option B: Active Lyric Line Only (Preserves Priority 1 without truncation)
            VStack(alignment: .leading) {
                Text(entry.lyric)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .minimumScaleFactor(0.65)
            }
        }
    }
}

// MARK: - 3. Circular Accessory View (accessoryCircular)
struct AccessoryCircularView: View {
    let entry: SimpleEntry

    var body: some View {
        Gauge(value: entry.progress, in: 0...1.0) {
            Image(systemName: "music.note")
        } currentValueLabel: {
            Text(entry.lyric.prefix(3).uppercased())
                .font(.system(size: 10, weight: .bold))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

// MARK: - 4. System Small View (systemSmall)
struct SystemSmallView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ViewThatFits(in: .vertical) {
                // Layout 1: Title Header + Active Lyric Line
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .foregroundColor(.green)
                            .font(.caption2)
                        Text(entry.title)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                    }

                    Text(entry.artist)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(entry.lyric)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }

                // Layout 2: Active Lyric Only (Fallback giving 100% space to Priority 1)
                VStack(alignment: .leading) {
                    Spacer(minLength: 0)

                    Text(entry.lyric)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.65)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }
            }
        }
        .padding()
        .containerBackground(.black, for: .widget)
    }
}

// MARK: - 5. System Medium View (systemMedium)
struct SystemMediumView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .vertical) {
                // Layout A: Metadata Header + Active Lyric + Next Lyric
                VStack(alignment: .leading, spacing: 6) {
                    headerView
                    activeLyricText
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLyricText(next)
                    }
                }

                // Layout B: Active Lyric + Next Lyric
                VStack(alignment: .leading, spacing: 6) {
                    activeLyricText
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLyricText(next)
                    }
                }

                // Layout C: Metadata Header + Active Lyric
                VStack(alignment: .leading, spacing: 6) {
                    headerView
                    activeLyricText
                }

                // Layout D: Active Lyric Line Only
                VStack(alignment: .leading) {
                    activeLyricText
                }
            }
        }
        .padding()
        .containerBackground(.black, for: .widget)
    }

    private var headerView: some View {
        HStack(spacing: 6) {
            Image(systemName: "music.note")
                .foregroundColor(.green)
                .font(.caption2)
            Text(entry.title)
                .font(.caption)
                .fontWeight(.bold)
                .lineLimit(1)
                .foregroundColor(.secondary)
            Text("•")
                .font(.caption2)
                .foregroundColor(.gray)
            Text(entry.artist)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }

    private var activeLyricText: some View {
        Text(entry.lyric)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func nextLyricText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(.secondary)
            .opacity(0.6)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
    }
}

// MARK: - 6. System Large View (systemLarge)
struct SystemLargeView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Section
            HStack(spacing: 12) {
                if let artwork = entry.artworkImage {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .cornerRadius(6)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.green)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(entry.artist)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                Spacer()
            }

            Divider()
                .background(Color.gray.opacity(0.4))

            // 3-Line Karaoke Sheet Stack
            ViewThatFits(in: .vertical) {
                // Layout 1: Active + Next + Following
                VStack(alignment: .leading, spacing: 12) {
                    activeLyricBlock
                    nextLyricBlock
                    followingLyricBlock
                }

                // Layout 2: Active + Next
                VStack(alignment: .leading, spacing: 12) {
                    activeLyricBlock
                    nextLyricBlock
                }

                // Layout 3: Active Line Only
                VStack(alignment: .leading, spacing: 12) {
                    activeLyricBlock
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(.black, for: .widget)
    }

    private var activeLyricBlock: some View {
        Text(entry.lyric)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var nextLyricBlock: some View {
        if let next = entry.nextLyric, !next.isEmpty {
            Text(next)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .opacity(0.6)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    @ViewBuilder
    private var followingLyricBlock: some View {
        if let following = entry.followingLyric, !following.isEmpty {
            Text(following)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .opacity(0.4)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
    }
}

// MARK: - 7. System Extra Large View (systemExtraLarge)
struct SystemExtraLargeView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack(spacing: 24) {
            // Left Dashboard Panel (35% Width)
            VStack(alignment: .leading, spacing: 12) {
                if let artwork = entry.artworkImage {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.0, contentMode: .fit)
                        .cornerRadius(12)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1.0, contentMode: .fit)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.largeTitle)
                                .foregroundColor(.green)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(entry.artist)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }

                ProgressView(value: entry.progress)
                    .tint(.green)

                Spacer(minLength: 0)
            }
            .frame(width: 200)

            Divider()
                .background(Color.gray.opacity(0.4))

            // Right Lyric Panel (65% Width)
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 0)

                // Active Lyric Line (The King)
                Text(entry.lyric)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)

                // Subsequent Lines Stack
                if let next = entry.nextLyric, !next.isEmpty {
                    Text(next)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(0.6)
                        .lineLimit(2)
                }

                if let following = entry.followingLyric, !following.isEmpty {
                    Text(following)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .opacity(0.4)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(20)
        .containerBackground(.black, for: .widget)
    }
}

// MARK: - Widget Router Entry View
struct CarLyricsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .systemSmall:
            SystemSmallView(entry: entry)
        case .systemMedium:
            SystemMediumView(entry: entry)
        case .systemLarge:
            SystemLargeView(entry: entry)
        case .systemExtraLarge:
            SystemExtraLargeView(entry: entry)
        @unknown default:
            SystemMediumView(entry: entry)
        }
    }
}

// MARK: - Main Widget Configuration
struct CarLyricsWidget: Widget {
    let kind: String = "CarLyricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CarLyricsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Car Lyrics")
        .description("Displays real-time song lyrics on your Home Screen, Lock Screen, and CarPlay widget stack.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

// MARK: - Xcode Canvas Previews
#Preview(as: .systemMedium) {
    CarLyricsWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        title: "Bohemian Rhapsody",
        artist: "Queen",
        lyric: "Is this the real life? Is this just fantasy?",
        nextLyric: "Caught in a landslide, no escape from reality",
        followingLyric: "Open your eyes, look up to the skies and see",
        progress: 0.2,
        artworkImage: nil
    )
    SimpleEntry(
        date: .now,
        title: "Hotel California",
        artist: "Eagles",
        lyric: "Welcome to the Hotel California",
        nextLyric: "Such a lovely place, such a lovely face",
        followingLyric: "Plenty of room at the Hotel California",
        progress: 0.5,
        artworkImage: nil
    )
}
