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
        static let currentTitle = "currentTitle"
        static let currentArtist = "currentArtist"
        static let previousLyric = "previousLyric"
        static let currentLyric = "currentLyric"
        static let nextLyric = "nextLyric"
        static let followingLyric = "followingLyric"
        static let progress = "progress"
        static let artworkPath = "currentArtworkUrl"
        static let platform = "widgetPlatform"
    }
}

// MARK: - Timeline Entry Model
struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let artist: String
    let previousLyric: String?
    let lyric: String // Active Lyric Line (Priority 1: The King)
    let nextLyric: String?
    let followingLyric: String?
    let progress: Double
    let artworkImage: UIImage?
    let platform: String

    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: Date(),
            title: "Bohemian Rhapsody",
            artist: "Queen",
            previousLyric: "Mama, just killed a man",
            lyric: "Is this the real life? Is this just fantasy?",
            nextLyric: "Caught in a landslide, no escape from reality",
            followingLyric: "Open your eyes, look up to the skies and see",
            progress: 0.35,
            artworkImage: nil,
            platform: "YouTube Music"
        )
    }

    static var empty: SimpleEntry {
        SimpleEntry(
            date: Date(),
            title: "No Track Playing",
            artist: "Car Lyrics",
            previousLyric: nil,
            lyric: "♪ Play music to display lyrics",
            nextLyric: nil,
            followingLyric: nil,
            progress: 0.0,
            artworkImage: nil,
            platform: "YouTube Music"
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
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func fetchSharedEntry() -> SimpleEntry {
        let defaults = UserDefaults(suiteName: AppGroup.suiteName)

        let title = defaults?.string(forKey: AppGroup.Keys.currentTitle) ?? "No Track Playing"
        let artist = defaults?.string(forKey: AppGroup.Keys.currentArtist) ?? "Car Lyrics"
        let previousLyric = defaults?.string(forKey: AppGroup.Keys.previousLyric)
        let lyric = defaults?.string(forKey: AppGroup.Keys.currentLyric) ?? "♪ Play music to display lyrics"
        let nextLyric = defaults?.string(forKey: AppGroup.Keys.nextLyric)
        let followingLyric = defaults?.string(forKey: AppGroup.Keys.followingLyric)
        let progress = defaults?.double(forKey: AppGroup.Keys.progress) ?? 0.0
        let platform = defaults?.string(forKey: AppGroup.Keys.platform) ?? "YouTube Music"

        var artworkImage: UIImage? = nil
        if let artworkPath = defaults?.string(forKey: AppGroup.Keys.artworkPath),
           let image = UIImage(contentsOfFile: artworkPath) {
            artworkImage = image
        }

        return SimpleEntry(
            date: Date(),
            title: title,
            artist: artist,
            previousLyric: previousLyric,
            lyric: lyric,
            nextLyric: nextLyric,
            followingLyric: followingLyric,
            progress: progress,
            artworkImage: artworkImage,
            platform: platform
        )
    }
}

// MARK: - 1. Inline Widget View (accessoryInline)
struct AccessoryInlineView: View {
    let entry: SimpleEntry

    var body: some View {
        ViewThatFits {
            Text("♪ \(entry.title): \(entry.lyric)")
                .lineLimit(1)
            Text("♪ \(entry.lyric)")
                .lineLimit(1)
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
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "music.note")
                        .font(.caption2)
                    Text(entry.title)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                }

                Text(entry.lyric)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }

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
            Text("🎤")
                .font(.system(size: 16))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

// MARK: - 4. System Small View (Standard Active Lyric Card)
struct SystemSmallView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ViewThatFits(in: .vertical) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .foregroundColor(.green)
                            .font(.caption2)
                        Text(entry.title)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .foregroundColor(.white.opacity(0.85))
                    }

                    Text(entry.artist)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.65))
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Text(entry.lyric)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.7)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)
                }

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
    }
}

// MARK: - Dedicated Small View: Dual Line (Active + Next)
struct SystemSmallDualView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ViewThatFits(in: .vertical) {
                // Tier 1 (Best Case): Title • Artist + Current Line (Full) + Next Line (Full or Truncated)
                VStack(alignment: .leading, spacing: 3) {
                    headerView
                    Spacer(minLength: 2)
                    currentLineStandard
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLineText(next, size: 11)
                    }
                    Spacer(minLength: 2)
                }

                // Tier 2 (Next Best Case): Current Line (Full, Standard Size) + Next Line (Truncated)
                VStack(alignment: .leading, spacing: 3) {
                    Spacer(minLength: 2)
                    currentLineStandard
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLineText(next, size: 11)
                    }
                    Spacer(minLength: 2)
                }

                // Tier 3 (Next Next Best Case): Current Line (Full, Adapted/Smaller Size) + Next Line (Truncated)
                // Font size adapts down to guarantee both current line and next line stay visible together
                VStack(alignment: .leading, spacing: 2) {
                    Spacer(minLength: 2)
                    currentLineAdapted
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLineText(next, size: 9.5)
                    }
                    Spacer(minLength: 2)
                }

                // Tier 4 (Worst Case): Only Current Line (100% space allocated, scales down so it NEVER cuts off)
                VStack(alignment: .leading, spacing: 0) {
                    Spacer(minLength: 0)
                    currentLineFailsafe
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(10)
        .containerBackground(.black, for: .widget)
        .widgetURL(URL(string: "carlyrics://"))
    }

    // Title & Artist Header
    private var headerView: some View {
        HStack(spacing: 3) {
            Image(systemName: "music.note")
                .foregroundColor(.green)
                .font(.system(size: 8, weight: .bold))
            Text("\(entry.title) • \(entry.artist)")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
        }
    }

    // Standard Size Current Line (lineLimit(nil) forces ViewThatFits to drop tier if text overflows)
    private var currentLineStandard: some View {
        Text(entry.lyric)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(nil)
            .minimumScaleFactor(0.85)
    }

    // Adapted/Smaller Size Current Line (Increases layout headroom to keep Next Line visible)
    private var currentLineAdapted: some View {
        Text(entry.lyric)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(nil)
            .minimumScaleFactor(0.75)
    }

    // Next Line (Truncates gracefully with "..." if space requires)
    private func nextLineText(_ text: String, size: CGFloat) -> some View {
        Text(text)
            .font(.system(size: size, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.75))
            .lineLimit(2)
            .minimumScaleFactor(0.8)
    }

    // Tier 4 Failsafe Current Line (Takes 100% vertical space and scales down to 0.5x)
    private var currentLineFailsafe: some View {
        Text(entry.lyric)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .lineLimit(4)
            .minimumScaleFactor(0.5)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 5. System Medium View (systemMedium)
struct SystemMediumView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ViewThatFits(in: .vertical) {
                VStack(alignment: .leading, spacing: 6) {
                    headerView
                    activeLyricText
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLyricText(next)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    activeLyricText
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLyricText(next)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    headerView
                    activeLyricText
                }

                VStack(alignment: .leading) {
                    activeLyricText
                }
            }
        }
        .padding()
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
                .foregroundColor(.white.opacity(0.85))
            Text("•")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
            Text(entry.artist)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
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
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.8))
            .lineLimit(2)
            .minimumScaleFactor(0.8)
    }
}

// MARK: - 6. System Large View (systemLarge)
struct SystemLargeView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                if let artwork = entry.artworkImage {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .cornerRadius(6)
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.15))
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
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)
                }

                Spacer()
            }

            Divider()
                .background(Color.white.opacity(0.3))

            ViewThatFits(in: .vertical) {
                VStack(alignment: .leading, spacing: 10) {
                    previousLyricBlock
                    activeLyricBlock
                    nextLyricBlock
                    followingLyricBlock
                }

                VStack(alignment: .leading, spacing: 10) {
                    previousLyricBlock
                    activeLyricBlock
                    nextLyricBlock
                }

                VStack(alignment: .leading, spacing: 10) {
                    activeLyricBlock
                    nextLyricBlock
                }

                VStack(alignment: .leading, spacing: 10) {
                    activeLyricBlock
                }
            }

            Spacer(minLength: 0)

            // Ultra-Minimal Low-Priority Indicator Footer
            if !entry.platform.isEmpty {
                Text("streaming from \(entry.platform)")
                    .font(.system(size: 8, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.35))
                    .lineLimit(1)
            }
        }
        .padding()
    }

    @ViewBuilder
    private var previousLyricBlock: some View {
        if let prev = entry.previousLyric, !prev.isEmpty {
            Text(prev)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.55))
                .lineLimit(1)
        }
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
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    @ViewBuilder
    private var followingLyricBlock: some View {
        if let following = entry.followingLyric, !following.isEmpty {
            Text(following)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.65))
                .lineLimit(1)
        }
    }
}

// MARK: - 7. System Extra Large View (systemExtraLarge)
struct SystemExtraLargeView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack(spacing: 24) {
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
                        .fill(Color.white.opacity(0.15))
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
                        .foregroundColor(.white.opacity(0.75))
                        .lineLimit(1)
                }

                ProgressView(value: entry.progress)
                    .tint(.green)

                if !entry.platform.isEmpty {
                    Text("streaming from \(entry.platform)")
                        .font(.system(size: 9, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .frame(width: 200)

            Divider()
                .background(Color.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 14) {
                Spacer(minLength: 0)

                if let prev = entry.previousLyric, !prev.isEmpty {
                    Text(prev)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                        .lineLimit(1)
                }

                Text(entry.lyric)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)

                if let next = entry.nextLyric, !next.isEmpty {
                    Text(next)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                }

                if let following = entry.followingLyric, !following.isEmpty {
                    Text(following)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(20)
    }
}

// MARK: - Widget Router Entry View
struct CarLyricsWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        Group {
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
        .widgetURL(URL(string: "carlyrics://"))
        .containerBackground(for: .widget) {
            if isAccessoryFamily(family) {
                Color.clear
            } else {
                Color.black
            }
        }
    }

    private func isAccessoryFamily(_ family: WidgetFamily) -> Bool {
        switch family {
        case .accessoryInline, .accessoryRectangular, .accessoryCircular:
            return true
        default:
            return false
        }
    }
}

// MARK: - Main Multi-Family Widget
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

// MARK: - Widget 2: Dual Line Small Widget
struct CarLyricsSmallDualWidget: Widget {
    let kind: String = "CarLyricsSmallDualWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SystemSmallDualView(entry: entry)
        }
        .configurationDisplayName("Lyrics - Active & Next")
        .description("Displays current and upcoming lyric lines in a small tile.")
        .supportedFamilies([.systemSmall])
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
        previousLyric: "Mama, just killed a man",
        lyric: "Is this the real life? Is this just fantasy?",
        nextLyric: "Caught in a landslide, no escape from reality",
        followingLyric: "Open your eyes, look up to the skies and see",
        progress: 0.2,
        artworkImage: nil,
        platform: "YouTube Music"
    )
}
