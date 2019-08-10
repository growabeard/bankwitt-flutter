#include "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"samples.flutter.dev/battery"
                                            binaryMessenger:controller];
    
    __weak typeof(self) weakSelf = self;
    [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        // Note: this method is invoked on the UI thread.
        if ([@"getBatteryLevel" isEqualToString:call.method]) {
            int batteryLevel = [weakSelf getBatteryLevel];
            NSLog(@"getBatteryLevel called with params: ");// + call.arguments.ToString());
            
            NSString *json = call.arguments;
            UIImage* image = [weakSelf generateBitmapFromJSONString:json];
            if (batteryLevel == -1) {
                result([FlutterError errorWithCode:@"UNAVAILABLE"
                                           message:@"Battery info unavailable"
                                           details:nil]);
            } else {
                result(@(batteryLevel));
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (UIImage*)generateBitmapFromJSONString:NSString {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(150, 150), NO, 0.0);
    UIImage *blankImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blankImage;
}

- (int)getBatteryLevel {
    UIDevice* device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        return -1;
    } else {
        return (int)(device.batteryLevel * 100);
    }
}

@end
