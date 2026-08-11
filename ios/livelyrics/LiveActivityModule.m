#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(LiveActivityModule, NSObject)
RCT_EXTERN_METHOD(startActivity:(NSString *)title artist:(NSString *)artist currentLine:(NSString *)currentLine)
RCT_EXTERN_METHOD(updateActivity:(NSString *)title artist:(NSString *)artist currentLine:(NSString *)currentLine)
RCT_EXTERN_METHOD(endActivity)
@end
