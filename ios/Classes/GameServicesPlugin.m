#import "GameServicesPlugin.h"
#import <game_services/game_services-Swift.h>

@implementation GameServicesPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGameServicesPlugin registerWithRegistrar:registrar];
}
@end
