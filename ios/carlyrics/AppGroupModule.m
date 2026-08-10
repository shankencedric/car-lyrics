#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AppGroupModule, NSObject)
RCT_EXTERN_METHOD(setLyricsData:(NSString *)title
                  artist:(NSString *)artist
                  previousLine:(NSString *)previousLine
                  currentLine:(NSString *)currentLine
                  nextLine:(NSString *)nextLine
                  followingLine:(NSString *)followingLine
                  artworkUrl:(NSString *)artworkUrl)
@end
