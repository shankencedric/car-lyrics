import ActivityKit
import WidgetKit
import SwiftUI

// 1. Define Activity Attributes and Dynamic Content State
public struct LyricsActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var currentLine: String
        public var nextLine: String?
        public var isPlaying: Bool
    }
    
    public var trackTitle: String
    public var artistName: String
}

// 2. SwiftUI Live Activity Widget View
@main
struct LyricsActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LyricsActivityAttributes.self) { context in
            // Lock Screen / Banner View
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "music.note")
                        .foregroundColor(.green)
                    Text("\(context.attributes.trackTitle) • \(context.attributes.artistName)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Text(context.state.currentLine)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let nextLine = context.state.nextLine, !nextLine.isEmpty {
                    Text(nextLine)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.85))
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View (Long Press on Island)
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.trackTitle, systemImage: "music.note")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.artistName)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .center, spacing: 2) {
                        Text(context.state.currentLine)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        if let nextLine = context.state.nextLine {
                            Text(nextLine)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Compact Left
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.green)
            } compactTrailing: {
                // Compact Right
                Text(context.state.currentLine)
                    .font(.caption2)
                    .frame(maxWidth: 80)
            } minimal: {
                // Minimal Icon View
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.green)
            }
        }
    }
}