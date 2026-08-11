//
//  LiveLyricsWidget.swift
//  LiveLyricsWidget
//
//  Created by Sean Ken Cedric Legara on 8/10/26.
//

import WidgetKit
import SwiftUI

// MARK: - App Group & Key Definitions
private enum AppGroup {
    static let suiteName = "group.com.shankencedric.livelyrics"

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
    let lyric: String
    let nextLyric: String?
    let followingLyric: String?
    let progress: Double
    let artworkImage: UIImage?
    let platform: String

    var cleanPlatform: String {
        platform.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var hasPlatform: Bool {
        let cleaned = cleanPlatform
        return !cleaned.isEmpty && cleaned != "null" && cleaned != "undefined"
    }

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
            artist: "LiveLyrics",
            previousLyric: nil,
            lyric: "",
            nextLyric: "♪ Play music to display lyrics",
            followingLyric: nil,
            progress: 0.0,
            artworkImage: nil,
            platform: ""
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
        let artist = defaults?.string(forKey: AppGroup.Keys.currentArtist) ?? "LiveLyrics"
        let previousLyric = defaults?.string(forKey: AppGroup.Keys.previousLyric)
        let lyric = defaults?.string(forKey: AppGroup.Keys.currentLyric) ?? ""
        let nextLyric = defaults?.string(forKey: AppGroup.Keys.nextLyric) ?? (title == "No Track Playing" ? "♪ Play music to display lyrics" : nil)
        let followingLyric = defaults?.string(forKey: AppGroup.Keys.followingLyric)
        let progress = defaults?.double(forKey: AppGroup.Keys.progress) ?? 0.0
        let platform = defaults?.string(forKey: AppGroup.Keys.platform) ?? ""

        let artworkPath = defaults?.string(forKey: AppGroup.Keys.artworkPath)
        let artworkImage = loadArtwork(from: artworkPath)

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

    // Robust Artwork Piping Helper (Supports POSIX path, file:// URI, and remote HTTP/HTTPS URLs)
    private func loadArtwork(from pathOrUrl: String?) -> UIImage? {
        guard let rawPath = pathOrUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !rawPath.isEmpty else {
            return nil
        }

        // 1. Direct POSIX File Path
        if FileManager.default.fileExists(atPath: rawPath), let image = UIImage(contentsOfFile: rawPath) {
            return image
        }

        // 2. file:// URL String
        if rawPath.hasPrefix("file://"), let url = URL(string: rawPath), let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }

        // 3. Remote Web URL (http/https)
        if (rawPath.hasPrefix("http://") || rawPath.hasPrefix("https://")), let url = URL(string: rawPath), let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }

        return nil
    }
}

// MARK: - 1. Inline Widget View (accessoryInline) - Left Anchored
struct AccessoryInlineView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack {
            ViewThatFits {
                Text("♪ \(entry.title): \(entry.lyric.isEmpty ? (entry.nextLyric ?? "") : entry.lyric)")
                    .lineLimit(1)
                Text("♪ \(entry.lyric.isEmpty ? (entry.nextLyric ?? "") : entry.lyric)")
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - 2. Rectangular Accessory View (accessoryRectangular) - Left Anchored
struct AccessoryRectangularView: View {
    let entry: SimpleEntry

    var body: some View {
        ViewThatFits(in: .vertical) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "music.note")
                        .font(.system(size: 8))
                    Text(entry.title)
                        .font(.system(size: 8.5, weight: .medium))
                        .lineLimit(1)
                }
                .foregroundColor(.white.opacity(0.6))

                Text(entry.lyric.isEmpty ? (entry.nextLyric ?? "") : entry.lyric)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }

            VStack(alignment: .leading) {
                Text(entry.lyric.isEmpty ? (entry.nextLyric ?? "") : entry.lyric)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .minimumScaleFactor(0.65)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .font(.system(size: 14))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

// MARK: - 4. System Small View (Standard Small Widget)
struct SystemSmallView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            // Header: Title Only
            HStack(spacing: 3) {
                Image(systemName: "music.note")
                    .foregroundColor(.green)
                    .font(.system(size: 9, weight: .bold))
                Text(entry.title)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 2)

            // Active Line Only
            Text(entry.lyric)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.65)
                .lineLimit(4)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 2)

            // Bottom Branding
            brandingFooter
        }
        .padding(12)
    }

    private var brandingFooter: some View {
        Group {
            if entry.hasPlatform {
                Text("\(Text("\(entry.cleanPlatform) • ").font(.system(size: 7.5, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 7.5, weight: .bold, design: .rounded)).foregroundColor(.green))")
            } else {
                Text("\(Text("sing-along thru ").font(.system(size: 7.5, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 7.5, weight: .bold, design: .rounded)).foregroundColor(.green))")
            }
        }
        .lineLimit(1)
    }
}

// MARK: - Dedicated Small View: Dual Line (Active + Next)
struct SystemSmallDualView: View {
    let entry: SimpleEntry

    // Adjusted threshold from 22 to 28 characters to prevent premature wrapping
    private var isTitleLong: Bool {
        entry.title.count > 28
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ViewThatFits(in: .vertical) {
                if !isTitleLong {
                    VStack(alignment: .center, spacing: 3) {
                        titleLine1ArtistLine2Header
                        Spacer(minLength: 2)
                        currentLineStandard
                        if let next = entry.nextLyric, !next.isEmpty {
                            nextLineText(next, size: 11)
                        }
                        Spacer(minLength: 2)
                        brandingFooter
                    }

                    VStack(alignment: .center, spacing: 3) {
                        titleOnlyHeader
                        Spacer(minLength: 2)
                        currentLineStandard
                        if let next = entry.nextLyric, !next.isEmpty {
                            nextLineText(next, size: 11)
                        }
                        Spacer(minLength: 2)
                        brandingFooter
                    }
                } else {
                    VStack(alignment: .center, spacing: 3) {
                        wrappedTitleArtistHeader
                        Spacer(minLength: 2)
                        currentLineStandard
                        if let next = entry.nextLyric, !next.isEmpty {
                            nextLineText(next, size: 11)
                        }
                        Spacer(minLength: 2)
                        brandingFooter
                    }
                }

                VStack(alignment: .center, spacing: 3) {
                    Spacer(minLength: 2)
                    currentLineStandard
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLineText(next, size: 11)
                    }
                    Spacer(minLength: 2)
                    brandingFooter
                }

                VStack(alignment: .center, spacing: 2) {
                    Spacer(minLength: 2)
                    currentLineAdapted
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLineText(next, size: 9.5)
                    }
                    Spacer(minLength: 2)
                    brandingFooter
                }

                VStack(alignment: .center, spacing: 0) {
                    Spacer(minLength: 0)
                    currentLineFailsafe
                    Spacer(minLength: 0)
                    brandingFooter
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(12)
        .containerBackground(.black, for: .widget)
        .widgetURL(URL(string: "livelyrics://"))
    }

    private var titleLine1ArtistLine2Header: some View {
        VStack(alignment: .center, spacing: 1) {
            HStack(spacing: 3) {
                Image(systemName: "music.note")
                    .foregroundColor(.green)
                    .font(.system(size: 8, weight: .bold))
                Text(entry.title)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }
            Text(entry.artist)
                .font(.system(size: 7.5, weight: .medium))
                .foregroundColor(.white.opacity(0.65))
                .lineLimit(1)
        }
    }

    private var wrappedTitleArtistHeader: some View {
        HStack(spacing: 3) {
            Image(systemName: "music.note")
                .foregroundColor(.green)
                .font(.system(size: 8, weight: .bold))
            Text("\(entry.title) • \(entry.artist)")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }

    private var titleOnlyHeader: some View {
        HStack(spacing: 3) {
            Image(systemName: "music.note")
                .foregroundColor(.green)
                .font(.system(size: 8, weight: .bold))
            Text(entry.title)
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
        }
    }

    private var currentLineStandard: some View {
        Text(entry.lyric)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.85)
            .frame(maxWidth: .infinity)
    }

    private var currentLineAdapted: some View {
        Text(entry.lyric)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity)
    }

    private func nextLineText(_ text: String, size: CGFloat) -> some View {
        Text(text)
            .font(.system(size: size, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.75))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }

    private var currentLineFailsafe: some View {
        Text(entry.lyric)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .lineLimit(4)
            .minimumScaleFactor(0.5)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    private var brandingFooter: some View {
        Group {
            if entry.hasPlatform {
                Text("\(Text("\(entry.cleanPlatform) • ").font(.system(size: 7.5, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 7.5, weight: .bold, design: .rounded)).foregroundColor(.green))")
            } else {
                Text("\(Text("sing-along thru ").font(.system(size: 7.5, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 7.5, weight: .bold, design: .rounded)).foregroundColor(.green))")
            }
        }
        .lineLimit(1)
    }
}

// MARK: - 5. System Medium View (Vertically Centered Above Branding Footer)
struct SystemMediumView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer(minLength: 0)

            ViewThatFits(in: .vertical) {
                VStack(alignment: .center, spacing: 6) {
                    headerView
                    activeLyricText
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLyricText(next)
                    }
                }

                VStack(alignment: .center, spacing: 6) {
                    activeLyricText
                    if let next = entry.nextLyric, !next.isEmpty {
                        nextLyricText(next)
                    }
                }

                VStack(alignment: .center, spacing: 6) {
                    headerView
                    activeLyricText
                }

                VStack(alignment: .center) {
                    activeLyricText
                }
            }

            Spacer(minLength: 0)

            brandingFooter
        }
        .padding(12)
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
            if entry.title != "No Track Playing" && !entry.artist.isEmpty {
                Text("•")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
                Text(entry.artist)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(1)
            }
        }
    }

    private var activeLyricText: some View {
        Text(entry.lyric)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    private func nextLyricText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.8))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
            .frame(maxWidth: .infinity)
    }

    private var brandingFooter: some View {
        Group {
            if entry.hasPlatform {
                Text("\(Text("streaming from \(entry.cleanPlatform) via ").font(.system(size: 8.5, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 8.5, weight: .bold, design: .rounded)).foregroundColor(.green))")
            } else {
                Text("\(Text("sing-along with your favorite platforms thru ").font(.system(size: 8.5, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 8.5, weight: .bold, design: .rounded)).foregroundColor(.green))")
            }
        }
        .lineLimit(1)
    }
}

// MARK: - 6. System Large View
struct SystemLargeView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection

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

            brandingFooter
        }
        .padding()
    }

    @ViewBuilder
    private var headerSection: some View {
        if entry.title == "No Track Playing" {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.green)
                    )
                Spacer()
            }
        } else {
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
        }
    }

    @ViewBuilder
    private var previousLyricBlock: some View {
        if let prev = entry.previousLyric, !prev.isEmpty {
            Text(prev)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .lineLimit(1)
        }
    }

    private var activeLyricBlock: some View {
        Text(entry.lyric)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .minimumScaleFactor(0.7)
            .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var nextLyricBlock: some View {
        if let next = entry.nextLyric, !next.isEmpty {
            Text(next)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
    }

    @ViewBuilder
    private var followingLyricBlock: some View {
        if let following = entry.followingLyric, !following.isEmpty {
            Text(following)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.35))
                .lineLimit(1)
        }
    }

    private var brandingFooter: some View {
        Group {
            if entry.hasPlatform {
                Text("\(Text("streaming from \(entry.cleanPlatform) via ").font(.system(size: 9, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(.green))")
            } else {
                Text("\(Text("sing-along with your favorite platforms thru ").font(.system(size: 9, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.4)))\(Text("LiveLyrics").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(.green))")
            }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - 7. System Extra Large View
struct SystemExtraLargeView: View {
    let entry: SimpleEntry

    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                if entry.title == "No Track Playing" {
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                            .aspectRatio(1.0, contentMode: .fit)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.largeTitle)
                                    .foregroundColor(.green)
                            )
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } else {
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
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
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

                brandingFooter

                Spacer(minLength: 0)
            }
            .frame(width: 200)

            Divider()
                .background(Color.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 14) {
                Spacer(minLength: 0)

                if let prev = entry.previousLyric, !prev.isEmpty {
                    Text(prev)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .lineLimit(1)
                }

                Text(entry.lyric)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)

                if let next = entry.nextLyric, !next.isEmpty {
                    Text(next)
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                }

                if let following = entry.followingLyric, !following.isEmpty {
                    Text(following)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(20)
    }

    private var brandingFooter: some View {
        Group {
            if entry.hasPlatform {
                Text("\(Text("streaming from \(entry.cleanPlatform) via ").font(.system(size: 10, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.5)))\(Text("LiveLyrics").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(.green))")
            } else {
                Text("\(Text("sing-along with your favorite platforms thru ").font(.system(size: 10, weight: .regular, design: .rounded)).foregroundColor(.white.opacity(0.5)))\(Text("LiveLyrics").font(.system(size: 10, weight: .bold, design: .rounded)).foregroundColor(.green))")
            }
        }
        .lineLimit(1)
    }
}

// MARK: - Widget Router Entry View
struct LiveLyricsWidgetEntryView: View {
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
        .widgetURL(URL(string: "livelyrics://"))
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
struct LiveLyricsWidget: Widget {
    let kind: String = "LiveLyricsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LiveLyricsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Live Lyrics")
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
        .contentMarginsDisabled()
    }
}

// MARK: - Widget 2: Dual Line Small Widget
struct LiveLyricsSmallDualWidget: Widget {
    let kind: String = "LiveLyricsSmallDualWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SystemSmallDualView(entry: entry)
        }
        .configurationDisplayName("Lyrics - Active & Next")
        .description("Displays current and upcoming lyric lines in a small tile.")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

// MARK: - Xcode Canvas Previews
#Preview(as: .systemMedium) {
    LiveLyricsWidget()
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
