#include "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"
#import "MMSpreadsheetView.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"samples.flutter.io/battery"
                                            binaryMessenger:controller];
    
    [batteryChannel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
        if ([@"getBatteryLevel" isEqualToString:call.method]) {
            [self shareFile:call.arguments
             withController:[UIApplication sharedApplication].keyWindow.rootViewController];
        }
    }];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)shareFile:(id)sharedItems withController:(UIViewController *)controller {
    
    NSString *json = sharedItems;
    UIImage* image = [self generateBitmapFromJSONString:json];
    
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[ image ]
                                      applicationActivities:nil];
    [controller presentViewController:activityViewController animated:YES completion:nil];
}

- (CGFloat)computeHeight:(NSUInteger)size {
    CGFloat height = 160.0;
    height += size * 25;
    return height;
}

- (UIImage*)buildImageOfStatement:(id)json {
    NSString *total = [json objectForKey:@"total"];
    
    NSDictionary *user = [json objectForKey:@"user"];
    NSArray *denominations = [json objectForKey:@"denominations"];
    
    NSString *first = (NSString*) [user valueForKey:@"first"];
    NSString *last = (NSString*) [user valueForKey:@"last"];
    
    CGFloat height = [self computeHeight:[denominations count]];
    
    UIGraphicsBeginImageContext(CGSizeMake(512.0, height));
    UIImage *statement = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    statement = [self drawFront:statement text:@"BANKWITT STATEMENT" atPoint:CGPointMake(0, 7)];
    statement = [self drawFront:statement text:[NSString stringWithFormat:@"%@ %@", first, last] atPoint:CGPointMake(0, 35)];
    statement = [self drawFront:statement text:@"Value" atPoint:CGPointMake(0, 65)];
    statement = [self drawFront:statement text:@"Name" atPoint:CGPointMake(150, 65)];
    statement = [self drawFront:statement text:@"Count" atPoint:CGPointMake(275, 65)];
    statement = [self drawFront:statement text:@"Total" atPoint:CGPointMake(400, 65)];
    
    NSLog(@"total %@ first  %@ last  %@", total, first, last);
    
    int i = 100;
    for (NSDictionary *denom in denominations){
        NSString *label = (NSString*) [denom valueForKey:@"label"];
        NSString *count = [NSString stringWithFormat:@"%@", [denom valueForKey:@"count"]];
        NSString *name = (NSString*) [denom valueForKey:@"name"];
        NSString *total = [NSString stringWithFormat:@"%@", [denom valueForKey:@"total"]];
        
        statement = [self drawFront:statement text:label atPoint:CGPointMake(0, i)];
        statement = [self drawFront:statement text:name atPoint:CGPointMake(150, i)];
        statement = [self drawFront:statement text:count atPoint:CGPointMake(275, i)];
        statement = [self drawFront:statement text:total atPoint:CGPointMake(400, i)];
        
        NSLog(@"label %@ count  %@ name  %@ total  %@", label, count, name, total);
        i = i + 25;
    }
    
    statement = [self drawFront:statement text:[NSString stringWithFormat:@"TOTAL: %@", total] atPoint:CGPointMake(0, height - 55)];
    statement = [self drawFront:statement text:@"Thank you for using BankWitt®©™!" atPoint:CGPointMake(0, height - 25)];
    
    return statement;
}

-(UIImage*)drawFront:(UIImage*)image text:(NSString*)text atPoint:(CGPoint)point
{
    UIFont *font = [UIFont systemFontOfSize:20.0];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, (point.y - 5), image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:font range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.76 green:0.76 blue:0.76 alpha:1.0] range:range];
    //c2c2c2
    
    [attString drawInRect:CGRectIntegral(rect)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*)generateBitmapFromJSONString:(NSString*)jsonString {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    UIImage *screenShot = [self buildImageOfStatement:json];
    
    return screenShot;
}

@end
