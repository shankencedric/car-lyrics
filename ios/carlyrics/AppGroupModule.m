#import "AppGroupModule.h"
#import <WidgetKit/WidgetKit.h>

@implementation AppGroupModule

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

RCT_EXPORT_METHOD(setLyricsData:(NSString *)title artist:(NSString *)artist lyric:(NSString *)lyric artworkUrl:(NSString *)artworkUrl)
{
  NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.shankencedric.carlyrics"];
  if (defaults) {
    [defaults setObject:title forKey:@"currentTitle"];
    [defaults setObject:artist forKey:@"currentArtist"];
    [defaults setObject:lyric forKey:@"currentLyric"];
    [defaults setObject:artworkUrl forKey:@"currentArtworkUrl"];
    [defaults synchronize];

    // Triggers WidgetKit to refresh widgets on Lock Screen & CarPlay
    if (@available(iOS 14.0, *)) {
      [WidgetCenter.sharedCenter reloadAllTimelines];
    }
  }
}

@end
