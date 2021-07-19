#import "EmojiPicker2Plugin.h"
#if __has_include(<emoji_picker_2/emoji_picker_2-Swift.h>)
#import <emoji_picker_2/emoji_picker_2-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "emoji_picker_2-Swift.h"
#endif

@implementation EmojiPicker2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEmojiPicker2Plugin registerWithRegistrar:registrar];
}
@end
