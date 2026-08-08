#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(CarPlayBridgeModule, NSObject)

RCT_EXTERN_METHOD(updateCarPlayLyrics:(NSString *)title
                  artist:(NSString *)artist
                  currentLine:(NSString *)currentLine
                  isPlaying:(BOOL)isPlaying
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end