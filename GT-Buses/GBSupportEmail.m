//
//  GBSupportEmail.m
//  GT-Buses
//
//  Created by Alex Perez on 9/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBSupportEmail.h"

#import "GBConstants.h"
#import "GBConfig.h"
#import "UIDevice+Hardware.h"
#import "GBAgency.h"

@import CoreLocation;

@implementation GBSupportEmail

+ (NSString *)subject {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"%@ Support", info[@"CFBundleDisplayName"]];
}

+ (NSString *)recipients {
    return @"support@iminichrispy.com";
}

+ (NSString *)body {
    NSMutableString *body = [NSMutableString new];
    [body appendFormat:@"\n\n\n%@", [self deviceInfo]];
    [body appendFormat:@"Location Services Enabled: %d\n", [CLLocationManager locationServicesEnabled]];
    [body appendFormat:@"Location Services Status: %d\n", [CLLocationManager authorizationStatus]];
    GBConfig *sharedConfig = [GBConfig sharedInstance];
    [body appendFormat:@"Agency: %@\n", [sharedConfig agency].tag];
    [body appendFormat:@"Shows Arrival Time: %d\n", [sharedConfig showsArrivalTime]];
    [body appendFormat:@"Shows Bus Identifiers: %d\n", [sharedConfig showsBusIdentifiers]];
    
    NSInteger color = [[NSUserDefaults standardUserDefaults] integerForKey:GBUserDefaultsSelectedColorKey];
    // If color is 0, it's the default color (which we don't care about)
    if (color) [body appendFormat:@"Color: %ld\n", (long)color];
    
    return body;
}

+ (NSString *)deviceInfo {
    static NSMutableString *deviceInfo;
    if (!deviceInfo) {
        // Cache this since it's not really going to change for a given execution
        deviceInfo = [NSMutableString stringWithString:@"<-------- Info -------->\n"];
        [deviceInfo appendString:@"Report Type: Support\n"];
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        [deviceInfo appendFormat:@"Product: %@\n", info[@"CFBundleDisplayName"]];
        [deviceInfo appendFormat:@"Version: %@\n", info[@"CFBundleShortVersionString"]];
        [deviceInfo appendFormat:@"Build: %@\n", info[@"CFBundleVersion"]];
        UIDevice *currentDevice = [UIDevice currentDevice];
        [deviceInfo appendFormat:@"Model: %@\n", [currentDevice model]];
        [deviceInfo appendFormat:@"Model Identifier: %@\n", [currentDevice machineName]];
        [deviceInfo appendFormat:@"System: %@ %@\n", [currentDevice systemName], [currentDevice systemVersion]];
        [deviceInfo appendFormat:@"Language: %@\n", [[NSLocale currentLocale] localeIdentifier]];
    }
    return deviceInfo;
}

@end
