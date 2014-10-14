//
//  GBSupportEmail.m
//  GT-Buses
//
//  Created by Alex Perez on 9/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSupportEmail.h"

#import "GBConstants.h"
#import <sys/utsname.h>

@import CoreLocation;


@implementation GBSupportEmail

+ (NSString *)subject {
    return @"GT Buses Support";
}

+ (NSString *)recipients {
    return @"support@iminichrispy.com";
}

+ (NSString *)body {
    NSMutableString *body = [NSMutableString new];
    [body appendFormat:@"\n\n\n%@", [self deviceInfo]];
    [body appendFormat:@"Location Services Enabled: %d\n", [CLLocationManager locationServicesEnabled]];
    [body appendFormat:@"Location Services Status: %d\n", [CLLocationManager authorizationStatus]];
    
    NSInteger color = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsKeySelectedColor];
    if (color) [body appendFormat:@"Color: %ld\n", (long)color];
    
    return body;
}

+ (NSString *)deviceInfo {
    static NSMutableString *deviceInfo;
    if (!deviceInfo) {
        deviceInfo = [NSMutableString stringWithString:@"<-------- Info -------->\n"];
        [deviceInfo appendString:@"Report Type: Support\n"];
        [deviceInfo appendString:@"Product: GT Buses\n"];
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        [deviceInfo appendFormat:@"Version: %@\n", info[@"CFBundleShortVersionString"]];
        [deviceInfo appendFormat:@"Build: %@\n", info[@"CFBundleVersion"]];
        [deviceInfo appendFormat:@"Model: %@\n", [[UIDevice currentDevice] model]];
        [deviceInfo appendFormat:@"Model Identifier: %@\n", [self machineName]];
        [deviceInfo appendFormat:@"System: %@ %@\n", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
        [deviceInfo appendFormat:@"Language: %@\n", [[NSLocale currentLocale] localeIdentifier]];
    }
    return deviceInfo;
}

+ (NSString *)machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end
