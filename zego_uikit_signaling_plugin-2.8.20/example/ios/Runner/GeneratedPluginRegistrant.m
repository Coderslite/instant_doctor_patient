//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_logs_yoer/FlutterLogsYoerPlugin.h>)
#import <flutter_logs_yoer/FlutterLogsYoerPlugin.h>
#else
@import flutter_logs_yoer;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

#if __has_include(<zego_callkit/ZegoCallkitPlugin.h>)
#import <zego_callkit/ZegoCallkitPlugin.h>
#else
@import zego_callkit;
#endif

#if __has_include(<zego_uikit_signaling_plugin/ZegoUikitSignalingPlugin.h>)
#import <zego_uikit_signaling_plugin/ZegoUikitSignalingPlugin.h>
#else
@import zego_uikit_signaling_plugin;
#endif

#if __has_include(<zego_zim/ZegoZimPlugin.h>)
#import <zego_zim/ZegoZimPlugin.h>
#else
@import zego_zim;
#endif

#if __has_include(<zego_zpns/ZegoZpnsPlugin.h>)
#import <zego_zpns/ZegoZpnsPlugin.h>
#else
@import zego_zpns;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterLogsYoerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterLogsYoerPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
  [ZegoCallkitPlugin registerWithRegistrar:[registry registrarForPlugin:@"ZegoCallkitPlugin"]];
  [ZegoUikitSignalingPlugin registerWithRegistrar:[registry registrarForPlugin:@"ZegoUikitSignalingPlugin"]];
  [ZegoZimPlugin registerWithRegistrar:[registry registrarForPlugin:@"ZegoZimPlugin"]];
  [ZegoZpnsPlugin registerWithRegistrar:[registry registrarForPlugin:@"ZegoZpnsPlugin"]];
}

@end
