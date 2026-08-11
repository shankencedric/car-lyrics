//
//  LiveLyricsWidgetLiveActivity.swift
//  LiveLyricsWidget
//

import ActivityKit
import WidgetKit
import SwiftUI

// 1. DATA MODEL: Matched to LiveActivityModule.swift
public struct LiveLyricsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var title: String
        var artist: String
        var lyric: String
    }
    var name: String
}

// 2. LIVE ACTIVITY & DYNAMIC ISLAND UI
struct LiveLyricsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveLyricsWidgetAttributes.self) { context in
            // Lock Screen Banner UI
            HStack(spacing: 12) {
                Image(systemName: "music.note.list")
                    .font(.title2)
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(context.state.title)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .lineLimit(1)
                        Text("• \(context.state.artist)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }

                    Text(context.state.lyric)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View (Long Press on Dynamic Island)
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "music.note")
                            .foregroundColor(.green)
                        Text(context.state.title)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.artist)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.lyric)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 4)
                }
            } compactLeading: {
                Image(systemName: "music.note")
                    .foregroundColor(.green)
            } compactTrailing: {
                Text(context.state.title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: 80)
            } minimal: {
                Image(systemName: "music.note")
                    .foregroundColor(.green)
            }
        }
    }
}
