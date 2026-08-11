//
//  LiveLyricsWidgetBundle.swift
//  LiveLyricsWidget
//
//  Created by Sean Ken Cedric Legara on 8/10/26.
//

import WidgetKit
import SwiftUI

@main
struct LiveLyricsWidgetBundle: WidgetBundle {
    var body: some Widget {
        LiveLyricsSmallDualWidget()
        LiveLyricsWidget()
        LiveLyricsWidgetLiveActivity()
    }
}
