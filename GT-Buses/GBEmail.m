//
//  GBEmail.m
//  GT-Buses
//
//  Created by Alex Perez on 9/15/14.
//  Copyright (c) 2014 Alex Perez. All rights reserved.
//

#import "GBEmail.h"

#import "GBConstants.h"
#import <sys/utsname.h>

@implementation GBEmail

+ (GBEmail *)defaultEmail {
    GBEmail *email = [[self alloc] init];
    email.subject = [self subject];
    email.recipients = [self recipients];
    email.body = [self body];
    return email;
}

+ (NSString *)subject {
    return nil; // To be implemented by subclasses
}

+ (NSString *)recipients {
    return nil; // To be implemented by subclasses
}

+ (NSString *)body {
    return nil; // To be implemented by subclasses
}

@end


@implementation GBSupportEmail

+ (NSString *)subject {
    return @"GT Buses Support";
}

+ (NSString *)recipients {
    return @"support@iminichrispy.com";
}

+ (NSString *)body {
    NSString *body = FORMAT(@"\n\n\n%@\n", [self deviceInfo]);
    return [body copy];
}

+ (NSString *)deviceInfo {
    static NSMutableString *deviceInfo;
    if (!deviceInfo) {
        deviceInfo = [NSMutableString stringWithString:@"<------- [Info] ------->\n"];
        [deviceInfo appendString:@"Report Type: Support\n"];
        [deviceInfo appendString:@"Product: GT Buses\n"];
        NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
        [deviceInfo appendString:FORMAT(@"Version: %@\n", info[@"CFBundleShortVersionString"])];
        [deviceInfo appendString:FORMAT(@"Build: %@\n", info[@"CFBundleVersion"])];
        [deviceInfo appendString:FORMAT(@"Model: %@\n", [[UIDevice currentDevice] model])];
        [deviceInfo appendString:FORMAT(@"Model Identifier: %@\n", [self machineName])];
        [deviceInfo appendString:FORMAT(@"System: %@ %@\n", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion])];
    }
    return deviceInfo;
}

+ (NSString *)machineName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end
